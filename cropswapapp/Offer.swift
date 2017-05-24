//
//  Offer.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/25/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Ax

struct Offer {
  
  var id: String?
  var dealId: String?
  var dateCreated: Double
  
  var ownerUserId: String?
  var ownerProduces: [(produceId: String, quantity: Int)]
  
  var anotherUserId: String?
  var anotherProduces: [(produceId: String, quantity: Int)]
  
  init(
    dealId: String,
    dateCreated: Double,
    anotherProduces: [(produceId: String, quantity: Int)],
    ownerProduces: [(produceId: String, quantity: Int)]
  ) {
    self.dealId = dealId
    self.dateCreated = dateCreated
    self.anotherProduces = anotherProduces
    self.ownerProduces = ownerProduces
  }
  
  init?(json: [String: Any]?) {
    guard
      let json = json,
      let id = json["id"] as? String,
      let dateCreated = json["dateCreated"] as? Double,
      let ownerUserId = json["ownerUserId"] as? String,
      let anotherUserId = json["anotherUserId"] as? String,
      let anotherProduces = json["anotherProduces"] as? [String: Int],
      let ownerProduces = json["ownerProduces"] as? [String: Int],
      let dealId = json["dealId"] as? String
      else {
        return nil
    }
    
    self.anotherUserId = anotherUserId
    self.ownerUserId = ownerUserId
    
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
    
    self.dealId = dealId
    self.id = id
    self.dateCreated = dateCreated
  }
}

extension Offer {
  
  static var refDatabase = CSFirebase.refDatabase
  static var refDatabaseOffers = refDatabase.child("offers")  
  
  static func makeAnotherOffer(
    originalOwnerUserId: String,
    newOwnerId ownerId: String,
    newAnotherId anotherId: String,
    
    newOwnerProduces ownerProduces: [(produceId: String, quantity: Int)],
    newAnotherProduces anotherProduces: [(produceId: String, quantity: Int)],
    
    dealId: String,
    dateCreated: Date,
    transactionMethod: String?,
    originalOwnerProducesCount: Int,
    originalAnotherProducesCount: Int,
    completion: @escaping (NSError?) -> Void
  ) {
    var offer = Offer(
      dealId: dealId,
      dateCreated: dateCreated.timeIntervalSince1970 * -1,
      anotherProduces: anotherProduces,
      ownerProduces: ownerProduces
    )
    
    offer.ownerUserId = ownerId
    offer.anotherUserId = anotherId
    
    Ax.parallel(tasks: [
      { done in
        create(offer) { (error) in
          done(error)
        }
      },
      
      { done in
        Deal.updateDeal(
          byId: dealId,
          newOwnerId: ownerId,
          newAnotherId: anotherId,
          newOwnerProduces: ownerProduces,
          newAnotherProduces: anotherProduces,
          dateCreated: dateCreated,
          transactionMethod: transactionMethod,
          originalOwnerUserId: originalOwnerUserId,
          originalOwnerProducesCount: originalOwnerProducesCount,
          originalAnotherProducesCount: originalAnotherProducesCount,
          completion: { (error) in
            done(error)
          }
        )
      }
    ]) { (error) in
      completion(error)
    }
  }
  
  static func getOffers(
    byDealId dealId: String,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    
    let refDatabaseOffersByDealId = refDatabaseOffers
                                        .child(dealId)
                                        .queryOrdered(byChild: "dateCreated")
    
    refDatabaseOffersByDealId.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      
      var offers = [[String: Any]]()
  
      if snap.exists() {
        if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          let baseGroup = DispatchGroup()
          
          dictionaries.forEach { snap in
            baseGroup.enter()
            
            let offer = Offer(json: snap.value as? [String: Any])
            var offerToReturn = [String: Any]()
            var anotherProduces = [(Produce, Int)]()
            var ownerProduces = [(Produce, Int)]()
            
            Ax.parallel(tasks: [
              
              { done in
                if let offer = offer {
                  let group = DispatchGroup()
                  
                  offer.anotherProduces.forEach {
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
                    offerToReturn["id"] = offer.id
                    offerToReturn["dateCreated"] = offer.dateCreated
                    offerToReturn["anotherUserId"] = offer.anotherUserId
                    offerToReturn["anotherProduces"] = anotherProduces
                    done(nil)
                  })
                  
                } else {
                  done(nil)
                }
              },
              
              { done in
                if let offer = offer {
                  let group = DispatchGroup()
                  
                  offer.ownerProduces.forEach {
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
                    offerToReturn["ownerProduces"] = ownerProduces
                    offerToReturn["ownerUserId"] = offer.ownerUserId
                    done(nil)
                  })
                } else {
                  done(nil)
                }
              }
              
            ], result: { (error) in
              offers.append(offerToReturn)
              baseGroup.leave()
            })
          }
          
          baseGroup.notify(queue: DispatchQueue.global(qos: .background), execute: { 
            completion(offers.sorted(by: { (offerA, offerB) -> Bool in
              let offerADate = offerA["dateCreated"] as? Double ?? 0
              let offerBDate = offerB["dateCreated"] as? Double ?? 0
              
              return offerADate < offerBDate
            }))
          })
        }
      }
    }
  }
  
  static func create(
    _ offer: Offer,
    completion: @escaping (NSError?) -> Void
  ) {
    guard let dealId = offer.dealId
    else {
      return
    }
    
    var refDatabaseOffer = refDatabaseOffers.child(dealId)
    refDatabaseOffer = refDatabaseOffer.childByAutoId()
    
    var ownerProduces = [String: Int]()
    var anotherProduces = [String: Int]()
    
    var values = [String: Any]()
    values["id"] = refDatabaseOffer.key
    values["dealId"] = dealId
    values["dateCreated"] = offer.dateCreated
    values["ownerUserId"] = offer.ownerUserId
    values["anotherUserId"] = offer.anotherUserId
//    values["transactionMethod"] = transactionMethod
    
    offer.ownerProduces.forEach {
      ownerProduces[$0.produceId] = $0.quantity
    }
    
    offer.anotherProduces.forEach {
      anotherProduces[$0.produceId] = $0.quantity
    }
    
    values["ownerProduces"] = ownerProduces
    values["anotherProduces"] = anotherProduces
    
    refDatabaseOffer.setValue(values, withCompletionBlock: {
      (error: Error?, ref: FIRDatabaseReference) in
  
      completion(error as NSError?)
    })
  }
}















































