//
//  ProduceWanted.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/16/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ProduceWanted {
  let id: String
  let name: String
  var quantityType: String?
  
  init(id: String, name: String) {
    self.name = name
    self.id = id
  }
  
  init?(json: [String: Any]?) {
    guard
      let json = json,
      let id = json["id"] as? String
    else {
      return nil
    }
    
    self.id = id
    self.name = json["name"] as? String ?? ""
    self.quantityType = json["quantityType"] as? String
  }
}


extension ProduceWanted {
  
  static let refDatabase = CSFirebase.refDatabase
  static let refDatabaseProduceTypes = refDatabase.child("produce-types")
  static let refDatabaseProducesWanted = refDatabase.child("produces-wanted")
  
  static func removeProduceWanted(
    toUserId userId: String,
    produceWantedId: String,
    completion: @escaping (NSError?) -> Void
  ) {
    let refDatabaseProducesWantedByUser = refDatabaseProducesWanted
                                            .child(userId)
                                            .child(produceWantedId)
    
    refDatabaseProducesWantedByUser.removeValue(
      completionBlock: { (error: Error?, ref: FIRDatabaseReference) in
        completion(error as? NSError)
      }
    )
  }
  
  static func addProduceWanted(
    toUserId userId: String,
    produceWantedId: String,
    completion: @escaping (NSError?) -> Void
  ) {
    
    let refDatabaseProducesWantedByUser = refDatabaseProducesWanted
                                            .child(userId)
                                            .child(produceWantedId)
    
    var values = [String: Any]()
    values["id"] = produceWantedId
    refDatabaseProducesWantedByUser.setValue(values)
    
    refDatabaseProducesWantedByUser.setValue(values, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as? NSError)
    })
  }
  
  static func getProducesWanted(ByUserId userId: String, completion: @escaping ([ProduceWanted]) -> Void) {
    refDatabaseProducesWanted
      .child(userId)
      .observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
        var producesWanted = [ProduceWanted]()
        
        if snap.exists() {
          if let array = snap.children.allObjects as? [FIRDataSnapshot] {
            producesWanted = array.flatMap { data in
              return ProduceWanted(json: data.value as? [String: Any])
            }
          }
        }
        
        completion(producesWanted)
    }
  }
  
  static func getProduceTypes(completion: @escaping ([ProduceWanted]) -> Void) {
    refDatabaseProduceTypes.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      var produceTypes = [ProduceWanted]()
      
      if snap.exists() {
        if let array = snap.children.allObjects as? [FIRDataSnapshot] {
          produceTypes = array.flatMap {
            return ProduceWanted(json: $0.value as? [String: Any])
          }
        }
      }
      
      completion(produceTypes)
    }
  }
}







































