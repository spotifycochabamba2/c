//
//  Deal.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/14/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Ax
import Alamofire
import SwiftyJSON

struct Deal {
  var id: String?
  
  var ownerUserId: String
  var anotherUserId: String
  
  var ownerUsername: String
  var anotherUsername: String
  
  var anotherPayWithMoney: Int = 0
  var anotherPayWithWork: Bool = false
  
  var ownerPayWithMoney: Int = 0
  var ownerPayWithWork: Bool = false
  
  // trade request (to user) / waiting answer (from user) (this goes to deal core)
  // trade completed
  // trade in process
  var state: DealState?
  
  // negative
  var dateCreated: Double
  
  var transactionMethod: String?
  
  var ownerProduces = [(produceId: String, quantity: Int)]()
  var anotherProduces = [(produceId: String, quantity: Int)]()
  
  var changes: [String: Any]?
  
  init?(json: [String: Any]?) {
    
    guard
      let json = json,
      let id = json["id"] as? String,
      let ownerUserId = json["ownerUserId"] as? String,
      let anotherUserId = json["anotherUserId"] as? String,
      let dateCreated = json["dateCreated"] as? Double
    else {
      return nil
    }
    
    self.id = id
    self.ownerUserId = ownerUserId
    self.anotherUserId = anotherUserId
    self.dateCreated = dateCreated
    
    let ownerProducesTemp = json["ownerProduces"] as? [String: Int] ?? [String: Int]()
    let anotherProducesTemp = json["anotherProduces"] as? [String: Int] ?? [String: Int]()
    
    self.ownerProduces = [(produceId: String, quantity: Int)]()
    for (key, value) in ownerProducesTemp {
      self.ownerProduces.append((produceId: key, quantity: value))
      print(self.ownerProduces.count)
    }
    
    self.anotherProduces = [(produceId: String, quantity: Int)]()
    for (key, value) in anotherProducesTemp {
      self.anotherProduces.append((produceId: key, quantity: value))
      print(self.anotherProduces.count)
    }
    
    self.state = DealState(rawValue: json["state"] as? String ?? DealState.waitingAnswer.rawValue)
    
    self.ownerUsername = json["ownerUsername"] as? String ?? ""
    self.anotherUsername = json["anotherUsername"] as? String ?? ""
    self.transactionMethod = json["transactionMethod"] as? String ?? ""
    
    self.changes = json["changes"] as? [String: Any]
    
    self.ownerPayWithWork = json["ownerPayWithWork"] as? Bool ?? false
    self.ownerPayWithMoney = json["ownerPayWithMoney"] as? Int ?? 0
    
    self.anotherPayWithWork = json["anotherPayWithWork"] as? Bool ?? false
    self.anotherPayWithMoney = json["anotherPayWithMoney"] as? Int ?? 0
  }
  
  init(
    ownerUserId: String,
    anotherUserId: String,
   
    ownerUsername: String,
    anotherUsername: String,
    
    ownerProduces: [[String: Any]],
    anotherProduces: [[String: Any]]
//    ownerProduces: [(produceId: String, quantity: Int)],
//    anotherProduces: [(produceId: String, quantity: Int)]
  ) {
    self.state = DealState.waitingAnswer
    self.dateCreated = Date().timeIntervalSince1970 * -1
    
    self.ownerUsername = ownerUsername
    self.anotherUsername = anotherUsername
    
    self.ownerUserId = ownerUserId
    self.anotherUserId = anotherUserId
    
//    var anotherPayWithMoney: Int = 0
//    var anotherPayWithWork: Bool = false
//    
//    var ownerPayWithMoney: Int = 0
//    var ownerPayWithWork: Bool = false
    
    self.ownerProduces = ownerProduces.flatMap {
      guard
          let produceId = $0["id"] as? String,
          let quantity = $0["quantityAdded"] as? Int
      else {
        return nil
      }
      
      if produceId == Constants.Ids.moneyId {
        ownerPayWithMoney = quantity
      } else if produceId == Constants.Ids.workerId {
        let isActive = $0["isActive"] as? Bool ?? false
        ownerPayWithWork = isActive
      } 
//      else {
        return (produceId: produceId, quantity: quantity)
//      }
    }
    
    self.anotherProduces = anotherProduces.flatMap {
      guard
        let produceId = $0["id"] as? String,
        let quantity = $0["quantityAdded"] as? Int
      else {
          return nil
      }
      
      if produceId == Constants.Ids.moneyId {
        anotherPayWithMoney = quantity
      } else if produceId == Constants.Ids.workerId {
        let isActive = $0["isActive"] as? Bool ?? false
        anotherPayWithWork = isActive
      } 
//      else
//      {
        return (produceId: produceId, quantity: quantity)
//      }
    }
  }
}

enum DealState: String {
  case tradeRequest = "Trade request"
  case waitingAnswer = "Waiting answer"
  case tradeInProcess = "Trade in process"
  case tradeCompleted = "Trade completed"
  case tradeCancelled = "Trade cancelled"
  case tradeDeleted = "Trade deleted"
}

enum HowFinalized: String {
  case illDrive = "I'll drive!"
  case youDriveIllTip = "You drive, I'll tip!"
  case letsMeetHalfway = "Let's meet halfway!"
}

extension Deal {
  
  static var refDatabase = CSFirebase.refDatabase
  static var refDatabaseDeals = refDatabase.child("deals")
  static var refDatabaseUserDeals = refDatabase.child("deals-by-user")
  static var refDatabaseUserToUserDeals = refDatabase.child("user-to-user-deals")
  
  static func anyActiveDeal(
    userOneId: String,
    userTwoId: String,
    completion: @escaping (Result<Bool>) -> Void
  ) {
    let url = "\(Constants.Server.stringURL)api/users/trade"
    
    var data = [String: Any]()
    data["userOneId"] = userOneId
    data["userTwoId"] = userTwoId
    
    Alamofire
      .request(
        url,
        method: .post,
        parameters: data,
        encoding: JSONEncoding.default
      )
      .validate()
      .responseJSON { (response) in
        switch response.result {
        case .success(let result):
          let result = result as? [String: Any]
          if result?["anyTradeActive"] as? Bool ?? false {
            completion(Result.success(data: true))
          } else {
            completion(Result.success(data: false))
          }
          
        case .failure(let error):
          print(error)
          let customError = NSError(domain: "Deal", code: 0, userInfo: [
            NSLocalizedDescriptionKey: error.localizedDescription
            ])
          completion(Result.fail(error: customError))
        }
    }
  }
  
  static func deleteDeal(
    byOwnerUserId ownerUserId: String,
    andAnotherUserId anotherUserId: String,
    andDealId dealId: String,
    completion: @escaping (NSError?) -> Void
  ) {
    
    var dealFound: Deal?
    
    Ax.serial(tasks: [
      
      { done in
        Deal.getDeal(byId: dealId, completion: { (result) in
          switch result {
          case .success(let deal):
            dealFound = deal
            done(nil)
          case .fail(let error):
            done(error)
          }
        })
      },
      
      { done in
        if let deal = dealFound {
          let dealState = deal.state ?? DealState.tradeDeleted
          
          CSNotification.saveOrUpdateTradeNotification(
            byUserId: ownerUserId,
            dealId: dealId,
            field: "trade",
            withValue: 0) { (error) in
              print(error)
          }
          
          if case DealState.tradeDeleted = dealState {
            //empty

            
            done(nil)
          } else{
            Deal.cancelDeal(
              ownerUserId: anotherUserId,
              anotherUserId: ownerUserId,
              dealId: dealId,
              dateUpdated: Date(),
              notifyUser: false,
              completion: { (error) in
                
                if error == nil {
                  let refDatabaseDeal = refDatabaseDeals.child(dealId)
                  
                  var values = [String: Any]()
                  values["state"] = DealState.tradeDeleted.rawValue
                  
                  refDatabaseDeal.updateChildValues(values)
                }
                
                done(error)
            })
          }
        } else {
          done(nil)
        }
      },
      
      { done in
        if dealFound != nil {
          let refDatabseUserDeal = refDatabaseUserDeals
                                                  .child(ownerUserId)
                                                  .child(dealId)
          
          var values = [String: Any]()
          values["state"] = DealState.tradeDeleted.rawValue
          
          refDatabseUserDeal.updateChildValues(values)
        }
        
        done(nil)
      }
      
    ]) { (error) in
      completion(error)
    }
    
    // get current state of deal
    //   - if state is not deleted
    //      - call Deal.cancelDeal then
    //      - set base Deal to deleted
    //   - set my deal side to deleted
    // NOTE: Check that in Trade List, deal deleted are not showed.
  }
  
  static func canUserMakeADeal(
    fromUserId: String,
    toUserId: String,
    completion: @escaping (Int) -> Void
  ) {
    
    let refDatabaseUserToUserDeal = refDatabaseUserToUserDeals
                                      .child(fromUserId)
                                      .child(toUserId)
    
    refDatabaseUserToUserDeal.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          var hoursLeftToReturn = 0
          
          for json in dictionaries {
            if let deal = json.value as? [String: Any] {
              let state = deal["state"] as? String ?? ""
              let utc = deal["date"] as? Double ?? 0
              let date = Date(timeIntervalSince1970: utc * -1)
              let seconds = date.timeIntervalSinceNow * -1
              let hours = 24 - (seconds / 3600)
              
              if DealState.waitingAnswer.rawValue == state,
                  (50 - seconds) > 0 {
//                hours > 0 {
//                hoursLeftToReturn = lround(hours)
                hoursLeftToReturn = lround(50 - seconds)
                break
              }
            }
          }
          
          completion(hoursLeftToReturn)
        } else {
          completion(0)
        }
      } else {
        completion(0)
      }
    }
  }
  
  static func cancelDeal(
    ownerUserId: String,
    anotherUserId: String,
    
    dealId: String,
    dateUpdated: Date,
    
    notifyUser: Bool = true,
    
    completion: @escaping (NSError?) -> Void
  ) {
    
    let refDatabseUserOneToUserTwoDeal = refDatabaseUserToUserDeals
      .child(ownerUserId)
      .child(anotherUserId)
      .child(dealId)
    
    let refDatabaseUserTwoToUserOneDeal = refDatabaseUserToUserDeals
      .child(anotherUserId)
      .child(ownerUserId)
      .child(dealId)
    
    var valuesForUserToUserDeal = [String: Any]()
    valuesForUserToUserDeal["state"] = DealState.tradeCancelled.rawValue
    valuesForUserToUserDeal["date"] = dateUpdated.timeIntervalSince1970 * -1
    
    refDatabseUserOneToUserTwoDeal.updateChildValues(valuesForUserToUserDeal)
    refDatabaseUserTwoToUserOneDeal.updateChildValues(valuesForUserToUserDeal)
    
    let refDatabaseDeal = refDatabaseDeals.child(dealId)
    
    let refDatabaseUserDealOwner = refDatabaseUserDeals.child(ownerUserId).child(dealId)
    let refDatabaseUserDealAnother = refDatabaseUserDeals.child(anotherUserId).child(dealId)
    
    var valuesForDeal = [String: Any]()
    valuesForDeal["state"] = DealState.tradeCancelled.rawValue
    valuesForDeal["dateUpdated"] = dateUpdated.timeIntervalSince1970 * -1
    
    var valuesForDealOwner = [String: Any]()
    valuesForDealOwner["state"] = DealState.tradeCancelled.rawValue
    valuesForDealOwner["dateCreated"] = dateUpdated.timeIntervalSince1970 * -1
    
    refDatabaseUserDealOwner.updateChildValues(valuesForDealOwner)
    refDatabaseUserDealAnother.updateChildValues(valuesForDealOwner)
    
    refDatabaseDeal.updateChildValues(valuesForDeal, withCompletionBlock: {
      (error: Error?, ref: FIRDatabaseReference) in
      
      
      print(ownerUserId)
      print(anotherUserId)
      
      User.sendDealPushNotification(
        ownerUserId: anotherUserId,
        anotherUserId: ownerUserId,
        dealId: dealId,
        dealState: DealState.tradeCancelled.rawValue,
        completion: { (error) in
          print(error)
      })
      
      CSNotification.saveOrUpdateTradeNotification(
        byUserId: ownerUserId,
        dealId: dealId,
        field: "trade",
        withValue: 1) { (error) in
          print(error)
      }
      
      CSNotification.createOrUpdateTradeNotification(
        withDealId: dealId,
        andUserId: ownerUserId,
        completion: { (error) in
          print(error)
        }
      )
      
//      if notifyUser {
//        User.sendDealPushNotification(
//          ownerUserId: anotherUserId,
//          anotherUserId: ownerUserId,
//          dealId: dealId,
//          dealState: DealState.tradeCancelled.rawValue,
//          completion: { (error) in
//            print(error)
//        })
//
//        CSNotification.saveOrUpdateTradeNotification(
//          byUserId: ownerUserId,
//          dealId: dealId,
//          field: "trade",
//          withValue: 1) { (error) in
//            print(error)
//        }
//        
//        CSNotification.createOrUpdateTradeNotification(
//          withDealId: dealId,
//          andUserId: ownerUserId,
//          completion: { (error) in
//            print(error)
//          }
//        )
//      } else {
//        // testing this part
//        User.sendDealPushNotification(
//          ownerUserId: anotherUserId,
//          anotherUserId: ownerUserId,
//          dealId: dealId,
//          dealState: DealState.tradeCancelled.rawValue,
//          completion: { (error) in
//            print(error)
//        })
//        
//        CSNotification.saveOrUpdateTradeNotification(
//          byUserId: ownerUserId,
//          dealId: dealId,
//          field: "trade",
//          withValue: 1) { (error) in
//            print(error)
//        }
//        
//        CSNotification.createOrUpdateTradeNotification(
//          withDealId: dealId,
//          andUserId: ownerUserId,
//          completion: { (error) in
//            print(error)
//          }
//        )
//      }
      
      completion(error as NSError?)
    })
    
  }
  
  static func acceptDeal(
    ownerUserId: String,
    anotherUserId: String,
    
    dealId: String,
    dateUpdated: Date,
    
//    howFinalized: String,
    
    completion: @escaping (NSError?) -> Void
  ) {
    
    let refDatabaseDeal = refDatabaseDeals.child(dealId)
    
    let refDatabaseUserDealOwner = refDatabaseUserDeals.child(ownerUserId).child(dealId)
    let refDatabaseUserDealAnother = refDatabaseUserDeals.child(anotherUserId).child(dealId)

    let refDatabseUserOneToUserTwoDeal = refDatabaseUserToUserDeals
      .child(ownerUserId)
      .child(anotherUserId)
      .child(dealId)
    
    let refDatabaseUserTwoToUserOneDeal = refDatabaseUserToUserDeals
      .child(anotherUserId)
      .child(ownerUserId)
      .child(dealId)
    
    var valuesForUserToUserDeal = [String: Any]()
    valuesForUserToUserDeal["state"] = DealState.tradeCompleted.rawValue
    valuesForUserToUserDeal["date"] = dateUpdated.timeIntervalSince1970 * -1
    
    refDatabseUserOneToUserTwoDeal.updateChildValues(valuesForUserToUserDeal)
    refDatabaseUserTwoToUserOneDeal.updateChildValues(valuesForUserToUserDeal)
    
    var valuesForDeal = [String: Any]()
    valuesForDeal["state"] = DealState.tradeCompleted.rawValue
//    valuesForDeal["howFinalized"] = howFinalized
    valuesForDeal["dateUpdated"] = dateUpdated.timeIntervalSince1970 * -1

    var valuesForDealOwner = [String: Any]()
    valuesForDealOwner["state"] = DealState.tradeCompleted.rawValue
    valuesForDealOwner["dateCreated"] = dateUpdated.timeIntervalSince1970 * -1
    
    refDatabaseUserDealOwner.updateChildValues(valuesForDealOwner)
    refDatabaseUserDealAnother.updateChildValues(valuesForDealOwner)
    
    refDatabaseDeal.updateChildValues(valuesForDeal, withCompletionBlock: {
      (error: Error?, ref: FIRDatabaseReference) in
      
      User.sendDealPushNotification(
        ownerUserId: anotherUserId,
        anotherUserId: ownerUserId,
        dealId: dealId,
        dealState: DealState.tradeCompleted.rawValue,
        completion: { (error) in
          print(error)
      })
      
      CSNotification.saveOrUpdateTradeNotification(
        byUserId: ownerUserId,
        dealId: dealId,
        field: "trade",
        withValue: 1) { (error) in
          print(error)
      }
      
      CSNotification.createOrUpdateTradeNotification(
        withDealId: dealId,
        andUserId: ownerUserId,
        completion: { (error) in
          print(error)
        }
      )
      
      completion(error as NSError?)
    })
  }
  
  static func updateDeal(
    byId dealId: String,
    
    newOwnerId ownerId: String,
    newAnotherId anotherId: String,
    
    newOwnerProduces: [(produceId: String, quantity: Int)],
    newAnotherProduces: [(produceId: String, quantity: Int)],
    
    dateCreated: Date,
    
    transactionMethod: String?,
    originalOwnerUserId: String,
    originalOwnerProducesCount: Int,
    originalAnotherProducesCount: Int,
    completion: @escaping (NSError?) -> Void
  ) {
    
    let refDatabaseDeal = refDatabaseDeals.child(dealId)
    
    let refDatabaseUserDealOwner = refDatabaseUserDeals.child(ownerId).child(dealId)
    let refDatabaseUserDealAnother = refDatabaseUserDeals.child(anotherId).child(dealId)
    
    var ownerProduces = [String: Int]()
    var anotherProduces = [String: Int]()
    
    var valuesForDeal = [String: Any]()
    
    let refDatabseUserOneToUserTwoDeal = refDatabaseUserToUserDeals
      .child(ownerId)
      .child(anotherId)
      .child(dealId)
    
    let refDatabaseUserTwoToUserOneDeal = refDatabaseUserToUserDeals
      .child(anotherId)
      .child(ownerId)
      .child(dealId)
    
    var valuesForUserToUserDeal = [String: Any]()
    valuesForUserToUserDeal["state"] = DealState.waitingAnswer.rawValue
    valuesForUserToUserDeal["date"] = dateCreated.timeIntervalSince1970 * -1
    
    refDatabseUserOneToUserTwoDeal.updateChildValues(valuesForUserToUserDeal)
    refDatabaseUserTwoToUserOneDeal.updateChildValues(valuesForUserToUserDeal)
    
    valuesForDeal["ownerUserId"] = ownerId
    valuesForDeal["anotherUserId"] = anotherId
    valuesForDeal["dateUpdated"] = dateCreated.timeIntervalSince1970 * -1
    
    let refDatabaseChanges = refDatabaseDeal
      .child("changes")
      .childByAutoId()
    
    var change = [String: Any]()
    
    change["timestamp"] = Date().timeIntervalSince1970
    
    if let transactionMethod = transactionMethod {
      valuesForDeal["transactionMethod"] = transactionMethod
      
      change["transactionMethod"] = transactionMethod
    }
    
    // filter money and pay with work
    // get money and pay with work values
    // and update properties
    
    var ownerPayWithMoney = 0
    var ownerPayWithWork = false
    
    var anotherPayWithMoney = 0
    var anotherPayWithWork = false
    
    let newOwnerProduces = newOwnerProduces.filter { (produce) -> Bool in
      let produceId = produce.produceId
      let value = produce.quantity
      
      if produceId == Constants.Ids.moneyId {
        ownerPayWithMoney = value
      } else if produceId == Constants.Ids.workerId {
        ownerPayWithWork = value > 0
      }
      
      return produceId != Constants.Ids.moneyId &&
              produceId != Constants.Ids.workerId
    }
    
    let newAnotherProduces = newAnotherProduces.filter {
      let produceId = $0.produceId
      let value = $0.quantity
      
      if produceId == Constants.Ids.moneyId {
        anotherPayWithMoney = value
      } else if produceId == Constants.Ids.workerId {
        anotherPayWithWork = value > 0
      }
      
      return produceId != Constants.Ids.moneyId &&
        produceId != Constants.Ids.workerId
    }
    
    valuesForDeal["ownerPayWithMoney"] = ownerPayWithMoney
    valuesForDeal["ownerPayWithWork"] = ownerPayWithWork
    
    valuesForDeal["anotherPayWithMoney"] = anotherPayWithMoney
    valuesForDeal["anotherPayWithWork"] = anotherPayWithWork
    
    // show in historical, using offer values => money and pay with
    // work have quantity as their storage variable name.
    var counterOwnerProduces = 0
    newOwnerProduces.forEach {
      counterOwnerProduces += $0.quantity
    }
    
    var counterAnotherProduces = 0
    newAnotherProduces.forEach {
      counterAnotherProduces += $0.quantity
    }
    
    let numberProducesTrade = counterOwnerProduces + counterAnotherProduces
    
    var valuesForUserDealOwner = [String: Any]()
    var valuesForUserDealAnother = [String: Any]()
    
    if originalOwnerUserId == ownerId {
      valuesForDeal["numberProducesTrade"] = numberProducesTrade
      valuesForDeal["originalOwnerProducesCount"] = counterOwnerProduces
      valuesForDeal["originalAnotherProducesCount"] = counterAnotherProduces
      
      valuesForUserDealOwner["numberProducesTrade"] = numberProducesTrade
      valuesForUserDealOwner["originalOwnerProducesCount"] = counterOwnerProduces
      valuesForUserDealOwner["originalAnotherProducesCount"] = counterAnotherProduces
      
      valuesForUserDealAnother["numberProducesTrade"] = numberProducesTrade
      valuesForUserDealAnother["originalOwnerProducesCount"] = counterOwnerProduces
      valuesForUserDealAnother["originalAnotherProducesCount"] = counterAnotherProduces
      
      if originalOwnerProducesCount != counterOwnerProduces {
        change[ownerId] = counterOwnerProduces
      }
      
      if originalAnotherProducesCount != counterAnotherProduces {
        change[anotherId] = counterAnotherProduces
      }
      
    } else {
      valuesForDeal["numberProducesTrade"] = numberProducesTrade
      valuesForDeal["originalOwnerProducesCount"] = counterAnotherProduces
      valuesForDeal["originalAnotherProducesCount"] = counterOwnerProduces
      
      valuesForUserDealOwner["numberProducesTrade"] = numberProducesTrade
      valuesForUserDealOwner["originalOwnerProducesCount"] = counterAnotherProduces
      valuesForUserDealOwner["originalAnotherProducesCount"] = counterOwnerProduces
      
      valuesForUserDealAnother["numberProducesTrade"] = numberProducesTrade
      valuesForUserDealAnother["originalOwnerProducesCount"] = counterAnotherProduces
      valuesForUserDealAnother["originalAnotherProducesCount"] = counterOwnerProduces
      
      if originalOwnerProducesCount != counterAnotherProduces {
        change[anotherId] = counterAnotherProduces
      }
      
      if originalAnotherProducesCount != counterOwnerProduces {
        change[ownerId] = counterOwnerProduces
      }
    }
    
    refDatabaseChanges
      .updateChildValues(change)
    
    newOwnerProduces.forEach {
      ownerProduces[$0.produceId] = $0.quantity
    }
    
    newAnotherProduces.forEach {
      anotherProduces[$0.produceId] = $0.quantity
    }
    
    valuesForDeal["ownerProduces"] = ownerProduces
    valuesForDeal["anotherProduces"] = anotherProduces
    
//    let numberProducesTrade = newAnotherProduces.count + newAnotherProduces.count
    
    
    valuesForUserDealOwner["state"] = DealState.waitingAnswer.rawValue
    valuesForUserDealOwner["dateCreated"] = dateCreated.timeIntervalSince1970 * -1
//    valuesForUserDealOwner["numberProducesTrade"] = numberProducesTrade
    
    
    valuesForUserDealAnother["state"] = DealState.tradeRequest.rawValue
    valuesForUserDealAnother["dateCreated"] = dateCreated.timeIntervalSince1970 * -1
//    valuesForUserDealAnother["numberProducesTrade"] = numberProducesTrade
    
    refDatabaseUserDealOwner.updateChildValues(valuesForUserDealOwner)
    refDatabaseUserDealAnother.updateChildValues(valuesForUserDealAnother)
    
    refDatabaseDeal.updateChildValues(valuesForDeal, withCompletionBlock: {
      (error: Error?, ref: FIRDatabaseReference) in
      
      User.sendDealPushNotification(
        ownerUserId: ownerId,
        anotherUserId: anotherId,
        dealId: dealId,
        dealState: DealState.waitingAnswer.rawValue,
        completion: { (error) in
          print(error)
      })
      
      CSNotification.saveOrUpdateTradeNotification(
        byUserId: anotherId,
        dealId: dealId,
        field: "trade",
        withValue: 1) { (error) in
          print(error)
      }
      
      CSNotification.createOrUpdateTradeNotification(
        withDealId: dealId,
        andUserId: anotherId,
        completion: { (error) in
          print(error)
        }
      )
      
      completion(error as NSError?)
    })
  }
  
  static func getDealProduces(byId dealId: String, completion: @escaping (_ ownerProduces:[(Produce, Int)], _ anotherProduces: [(Produce, Int)], Deal) -> Void) {

    let refDatabaseDeal = refDatabaseDeals
                              .child(dealId)
                              .queryOrdered(byChild: "dateCreated")
    
    refDatabaseDeal.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if let deal = Deal(json: snap.value as? [String: Any]) {
          var anotherProduces = [(Produce, Int)]()
          var ownerProduces = [(Produce, Int)]()
          
          Ax.parallel(tasks: [
            
            { done in
              let group = DispatchGroup()
              
              deal.anotherProduces.forEach {
                group.enter()
                let quantity = $0.quantity
                
                Produce.getProduce(byProduceId: $0.produceId, completion: { (produce) in
                  if let produce = produce {
                    anotherProduces.append((produce, quantity))
                  }
                  group.leave()
                })
              }
              
              group.notify(queue: DispatchQueue.global(qos: .background), execute: {
                done(nil)
              })
            },
            
            { done in
              let group = DispatchGroup()
              
              deal.ownerProduces.forEach {
                group.enter()
                let quantity = $0.quantity
                
                Produce.getProduce(byProduceId: $0.produceId, completion: { (produce) in
                  if let produce = produce {
                    ownerProduces.append((produce, quantity))
                  }
                  
                  group.leave()
                })
              }
              
              group.notify(queue: DispatchQueue.global(qos: .background), execute: {
                done(nil)
              })
            }
            
            ], result: { (error) in
              completion(ownerProduces, anotherProduces, deal)
            }
          )
        }
      }
    }
  }
  
  static func getDeal(byId dealId: String, completion: @escaping (Result<Deal>) -> Void) {
    
    let refDatabaseDeal = refDatabaseDeals.child(dealId)
    
    refDatabaseDeal.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      
      if snap.exists() {
        if let deal = Deal(json: snap.value as? [String: Any]) {
          completion(Result.success(data: deal))
        } else {
          let error = NSError(domain: "Deal", code: 0, userInfo: [NSLocalizedDescriptionKey: "Deal data is inconsistent in database."])
          completion(Result.fail(error: error))
        }
      } else {
        let error = NSError(domain: "Deal", code: 0, userInfo: [NSLocalizedDescriptionKey: "No deal found."])
        completion(Result.fail(error: error))
      }
    }
    
  }
  
  static func getDeals(byUserId userId: String, completion: @escaping ([[String: Any]]) -> Void) -> UInt {
    let refDatabaseDeals = refDatabaseUserDeals
                                .child(userId)
                                .queryOrdered(byChild: "dateCreated")
    
    return refDatabaseDeals.observe(.value) { (snapshot: FIRDataSnapshot) in
      var deals = [[String: Any]]()
      
      if snapshot.exists() {
        
        if let dictionaries = snapshot.children.allObjects as? [FIRDataSnapshot] {
          
          dictionaries.forEach {
            if let item = $0.value as? [String: Any] {
              deals.append(item)
            }
          }
          
          let group = DispatchGroup()
          for (index, deal) in deals.enumerated() {
            group.enter()
            
            if let userId = deal["anotherUserId"] as? String {
              User.getUser(byUserId: userId, completion: { (result) in
                switch result {
                case .success(let user):
                  print(index)
                  deals[index]["anotherUsername"] = user.name
                  deals[index]["anotherProfilePictureURL"] = user.profilePictureURL
                case .fail(let error):
                  print(error)
                }
                
                group.leave()
              })
            } else {
              group.leave()
            }
          }
          
          group.notify(queue: DispatchQueue.global(qos: .background), execute: {
            completion(deals)
            
          })
          
          //          Ax.parallel(tasks: [
          //            { done in
          //              let group = DispatchGroup()
          //              for (index, deal) in deals.enumerated() {
          //                group.enter()
          //
          //                if let userId = deal["anotherUserId"] as? String {
          //                  User.getUser(byUserId: userId, completion: { (result) in
          //                    switch result {
          //                    case .success(let user):
          //                      print(index)
          //                      deals[index]["anotherUsername"] = user.name
          //                      deals[index]["anotherProfilePictureURL"] = user.profilePictureURL
          //                    case .fail(let error):
          //                      print(error)
          //                    }
          //
          //                    group.leave()
          //                  })
          //                } else {
          //                  group.leave()
          //                }
          //              }
          //
          //              group.notify(queue: DispatchQueue.global(qos: .background), execute: {
          //                done(nil)
          //
          //              })
          //            },
          //
          //            { done in
          //              let group2 = DispatchGroup()
          //              for (index, deal) in deals.enumerated() {
          //                group2.enter()
          //
          //                if let dealId = deal["id"] as? String {
          //                  CSNotification.getNotification(
          //                    byUserId: userId,
          //                    andDealId: dealId,
          //                    completion: { (notification) in
          //                      deals[index]["notifications"] = notification
          //                      group2.leave()
          //                  })
          //                } else {
          //                  group2.leave()
          //                }
          //              }
          //              
          //              group2.notify(queue: DispatchQueue.global(qos: .background), execute: {
          //                done(nil)
          //              })
          //            }
          //          ], result: { (error) in
          //            print(deals)
          //            completion(deals)
          //          })
        } else {
          completion(deals)
        }
      } else {
        completion(deals)
      }
    }
  }
  
  static func removeListentingDealsUpdated(byUserId userId: String, handlerId: UInt) {
    let refDatabaseDeals = refDatabaseUserDeals
                                .child(userId)
    refDatabaseDeals.removeObserver(withHandle: handlerId)
  }
  
  static func getDealsByListeningUpdatedOnes(byUserId userId: String, completion: @escaping ([String: Any]) -> Void) -> UInt {
    let refDatabaseDeals = refDatabaseUserDeals
                              .child(userId)
    
    return refDatabaseDeals.observe(.childChanged, with: { (snap) in
      if snap.exists() {
        if let deal = snap.value as? [String: Any] {
          completion(deal)
        }
      }
    })
    
  }
  
  
  static func create(_ deal: Deal, completion: @escaping (NSError?) -> Void) {
    let refDatabaseDeal = refDatabaseDeals.childByAutoId()
    let dealKey = refDatabaseDeal.key
    
    let refDatabaseUserDealOwner = refDatabaseUserDeals.child(deal.ownerUserId).child(dealKey)
    let refDatabaseUserDealAnother = refDatabaseUserDeals.child(deal.anotherUserId).child(dealKey)
    
    let refDatabseUserOneToUserTwoDeal = refDatabaseUserToUserDeals
                                          .child(deal.ownerUserId)
                                          .child(deal.anotherUserId)
                                          .child(dealKey)
    
    let refDatabaseUserTwoToUserOneDeal = refDatabaseUserToUserDeals
                                          .child(deal.anotherUserId)
                                          .child(deal.ownerUserId)
                                          .child(dealKey)
    
    var offer = Offer(
      dealId: dealKey,
      dateCreated: deal.dateCreated,
      anotherProduces: deal.anotherProduces,
      ownerProduces: deal.ownerProduces
    )
    
    //      if produceId == Constants.Ids.moneyId {
    //        ownerPayWithMoney = quantity
    //        return nil
    //      } else if produceId == Constants.Ids.workerId {
    //        let isActive = $0["isActive"] as? Bool ?? false
    //        ownerPayWithWork = isActive
    //        return nil
    
//    anotherProduces
    let anotherProduces = deal.anotherProduces.filter {
      return $0.produceId != Constants.Ids.moneyId &&
              $0.produceId != Constants.Ids.workerId
    }
    
    let ownerProduces = deal.ownerProduces.filter {
      return $0.produceId != Constants.Ids.moneyId &&
        $0.produceId != Constants.Ids.workerId
    }
    
    offer.ownerUserId = deal.ownerUserId
    offer.anotherUserId = deal.anotherUserId
    
    var counterOwnerProduces = 0
    ownerProduces.forEach {
      counterOwnerProduces += $0.quantity
    }
    
    var counterAnotherProduces = 0
    anotherProduces.forEach {
      counterAnotherProduces += $0.quantity
    }
    
    let numberProducesTrade = counterOwnerProduces + counterAnotherProduces
    
    var valuesForUserToUserDeal = [String: Any]()
    valuesForUserToUserDeal["id"] = dealKey
    valuesForUserToUserDeal["state"] = DealState.waitingAnswer.rawValue
    valuesForUserToUserDeal["date"] = Date().timeIntervalSince1970 * -1
    
    refDatabseUserOneToUserTwoDeal.setValue(valuesForUserToUserDeal)
    refDatabaseUserTwoToUserOneDeal.setValue(valuesForUserToUserDeal)
    
    var valuesForDeal = [String: Any]()
    valuesForDeal["id"] = dealKey
    valuesForDeal["ownerUserId"] = deal.ownerUserId
    valuesForDeal["ownerUsername"] = deal.ownerUsername
    valuesForDeal["anotherUserId"] = deal.anotherUserId
    valuesForDeal["state"] = deal.state?.rawValue ?? DealState.waitingAnswer.rawValue
    valuesForDeal["dateCreated"] = deal.dateCreated
    valuesForDeal["originalOwnerUserId"] = deal.ownerUserId
    valuesForDeal["originalOwnerProducesCount"] = counterOwnerProduces
    valuesForDeal["originalAnotherProducesCount"] = counterAnotherProduces
    valuesForDeal["transactionMethod"] = deal.transactionMethod ?? ""
    
    valuesForDeal["ownerPayWithMoney"] = deal.ownerPayWithMoney
    valuesForDeal["ownerPayWithWork"] = deal.ownerPayWithWork
    valuesForDeal["anotherPayWithMoney"] = deal.anotherPayWithMoney
    valuesForDeal["anotherPayWithWork"] = deal.anotherPayWithWork
    
    var valuesForUserDealOwner = [String: Any]()
    valuesForUserDealOwner["id"] = dealKey
    valuesForUserDealOwner["state"] = DealState.tradeRequest.rawValue
    valuesForUserDealOwner["dateCreated"] = deal.dateCreated
    valuesForUserDealOwner["anotherUserId"] = deal.ownerUserId
    valuesForUserDealOwner["anotherUsername"] = deal.ownerUsername
    valuesForUserDealOwner["originalOwnerUserId"] = deal.ownerUserId
    valuesForUserDealOwner["numberProducesTrade"] = numberProducesTrade
    valuesForUserDealOwner["originalOwnerProducesCount"] = counterOwnerProduces
    valuesForUserDealOwner["originalAnotherProducesCount"] = counterAnotherProduces
    
    var valuesForUserDealAnother = [String: Any]()
    valuesForUserDealAnother["id"] = dealKey
    valuesForUserDealAnother["state"] = DealState.waitingAnswer.rawValue
    valuesForUserDealAnother["dateCreated"] = deal.dateCreated
    valuesForUserDealAnother["anotherUserId"] = deal.anotherUserId
    valuesForUserDealAnother["anotherUsername"] = deal.anotherUsername
    valuesForUserDealAnother["originalOwnerUserId"] = deal.ownerUserId
    valuesForUserDealAnother["numberProducesTrade"] = numberProducesTrade
    valuesForUserDealAnother["originalOwnerProducesCount"] = counterOwnerProduces
    valuesForUserDealAnother["originalAnotherProducesCount"] = counterAnotherProduces
    
    var ownerProducesTemp = [String: Int]()
    var anotherProducesTemp = [String: Int]()
    
    ownerProduces.forEach {
      ownerProducesTemp[$0.produceId] = $0.quantity
    }
    
    anotherProduces.forEach {
      anotherProducesTemp[$0.produceId] = $0.quantity
    }
  
    valuesForDeal["ownerProduces"] = ownerProducesTemp
    valuesForDeal["anotherProduces"] = anotherProducesTemp
    
    refDatabaseUserDealOwner.setValue(valuesForUserDealAnother)
    refDatabaseUserDealAnother.setValue(valuesForUserDealOwner)
    
    Offer.create(offer) { (error) in
      print(error)
    }
    
    
    refDatabaseDeal.setValue(valuesForDeal, withCompletionBlock: {
      (error: Error?, ref: FIRDatabaseReference) in
      completion(error as NSError?)
      
      User.sendDealPushNotification(
        ownerUserId: deal.ownerUserId,
        anotherUserId: deal.anotherUserId,
        dealId: dealKey,
        dealState: DealState.waitingAnswer.rawValue,
        completion: { (error) in
          print(error)
      })
      
      CSNotification.saveOrUpdateTradeNotification(
        byUserId: deal.anotherUserId,
        dealId: dealKey,
        field: "trade",
        withValue: 1) { (error) in
          print(error)
      }

      CSNotification.createOrUpdateTradeNotification(
        withDealId: dealKey,
        andUserId: deal.anotherUserId,
        completion: { (error) in
          print(error)
        }
      )
    })
  }
}

















































