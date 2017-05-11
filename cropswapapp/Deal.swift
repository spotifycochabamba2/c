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

struct Deal {
  var id: String?
  
  var ownerUserId: String
  var anotherUserId: String
  
  var ownerUsername: String
  var anotherUsername: String
  
  // trade request (to user) / waiting answer (from user) (this goes to deal core)
  // trade completed
  // trade in process
  var state: DealState?
  
  // negative
  var dateCreated: Double
  
  var transactionMethod: String?
  
  var ownerProduces: [(produceId: String, quantity: Int)]
  var anotherProduces: [(produceId: String, quantity: Int)]
  
  var changes: [String: Any]?
  
  init?(json: [String: Any]?) {
    
    guard
      let json = json,
      let id = json["id"] as? String,
      let ownerUserId = json["ownerUserId"] as? String,
      let anotherUserId = json["anotherUserId"] as? String,
      let dateCreated = json["dateCreated"] as? Double,
      let anotherProduces = json["anotherProduces"] as? [String: Int],
      let ownerProduces = json["ownerProduces"] as? [String: Int]
    else {
      return nil
    }
    
    self.id = id
    self.ownerUserId = ownerUserId
    self.anotherUserId = anotherUserId
    self.dateCreated = dateCreated
    
    self.ownerProduces = [(produceId: String, quantity: Int)]()
    for (key, value) in ownerProduces {
      self.ownerProduces.append((produceId: key, quantity: value))
      print(self.ownerProduces.count)
    }
    
    self.anotherProduces = [(produceId: String, quantity: Int)]()
    for (key, value) in anotherProduces {
      self.anotherProduces.append((produceId: key, quantity: value))
      print(self.anotherProduces.count)
    }
    
    self.state = DealState(rawValue: json["state"] as? String ?? DealState.waitingAnswer.rawValue)
    
    self.ownerUsername = json["ownerUsername"] as? String ?? ""
    self.anotherUsername = json["anotherUsername"] as? String ?? ""
    self.transactionMethod = json["transactionMethod"] as? String ?? ""
    
    self.changes = json["changes"] as? [String: Any]
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
    
    self.ownerProduces = ownerProduces.flatMap {
      guard
          let produceId = $0["id"] as? String,
          let quantity = $0["quantityAdded"] as? Int
      else {
        return nil
      }
      
      return (produceId: produceId, quantity: quantity)
    }
    
    self.anotherProduces = anotherProduces.flatMap {
      guard
        let produceId = $0["id"] as? String,
        let quantity = $0["quantityAdded"] as? Int
        else {
          return nil
      }
      
      return (produceId: produceId, quantity: quantity)
    }
  }
}

enum DealState: String {
  case tradeRequest = "Trade request"
  case waitingAnswer = "Waiting answer"
  case tradeInProcess = "Trade in process"
  case tradeCompleted = "Trade completed"
  case tradeCancelled = "Trade cancelled"
}

enum HowFinalized: String {
  case illDrive = "I'll drive!"
  case youDriveIllTip = "You drive, I'll tip!"
  case letsMeetHalfway = "Let's meet halfway!"
}

extension Deal {
  
  static var refDatabase = FIRDatabase.database().reference()
  static var refDatabaseDeals = refDatabase.child("deals")
  static var refDatabaseUserDeals = refDatabase.child("deals-by-user")
  
  static func cancelDeal(
    ownerUserId: String,
    anotherUserId: String,
    
    dealId: String,
    dateUpdated: Date,
    
    completion: @escaping (NSError?) -> Void
  ) {
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
      
      User.sendDealPushNotification(
        ownerUserId: anotherUserId,
        anotherUserId: ownerUserId,
        dealId: dealId,
        dealState: DealState.tradeCancelled.rawValue,
        completion: { (error) in
          print(error)
      })
      
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
    
    print(refDatabaseDeal.url)
    print(refDatabaseUserDealOwner.url)
    print(refDatabaseUserDealAnother.url)
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
  
  static func getDealProduces(byId dealId: String, completion: @escaping (_ ownerProduces:[(Produce, Int)], _ anotherProduces: [(Produce, Int)]) -> Void) {

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
              completion(ownerProduces, anotherProduces)
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
    
    var offer = Offer(
      dealId: dealKey,
      dateCreated: deal.dateCreated,
      anotherProduces: deal.anotherProduces,
      ownerProduces: deal.ownerProduces
    )
    
    offer.ownerUserId = deal.ownerUserId
    offer.anotherUserId = deal.anotherUserId
    
    var counterOwnerProduces = 0
    deal.ownerProduces.forEach {
      counterOwnerProduces += $0.quantity
    }
    
    var counterAnotherProduces = 0
    deal.anotherProduces.forEach {
      counterAnotherProduces += $0.quantity
    }
    
    let numberProducesTrade = counterOwnerProduces + counterAnotherProduces
    
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
    print(valuesForUserDealOwner)
    
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
    
    var ownerProduces = [String: Int]()
    var anotherProduces = [String: Int]()
    
    deal.ownerProduces.forEach {
      ownerProduces[$0.produceId] = $0.quantity
    }
    
    deal.anotherProduces.forEach {
      anotherProduces[$0.produceId] = $0.quantity
    }
  
    valuesForDeal["ownerProduces"] = ownerProduces
    valuesForDeal["anotherProduces"] = anotherProduces
    
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

















































