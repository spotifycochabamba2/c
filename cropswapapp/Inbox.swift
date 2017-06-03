//
//  Inbox.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/1/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON
import Alamofire

struct Inbox {
  
}

extension Inbox {
  
  static let refDatabase = CSFirebase.refDatabase
  static let refInbox = refDatabase.child("inbox")
  static let refMessages = refDatabase.child("messages")
  
  static func listenUpdatesInbox(
    byUserId userId: String,
    completion: @escaping(Int) -> Void
  ) -> UInt {
    let refInboxUser = refInbox.child(userId)
    
    return refInboxUser.observe(.value) { (snap: FIRDataSnapshot) in
      var numberOfNotifications = 0
      
      if snap.exists() {
        if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          print(dictionaries)
          dictionaries.forEach {
            var inbox = $0.value as? [String: Any]
            
            if let notifications = inbox?["notifications"] as? Int {
              if notifications > 0 {
                numberOfNotifications += 1
              }
            }
          }
          
        }
      }
      
      completion(numberOfNotifications)
    }
  }
  
  static func unListenUpdateInbox(
    byUserId userId: String,
    handlerId: UInt
  ) {
    let refInboxUser = refInbox.child(userId)
    refInboxUser.removeObserver(withHandle: handlerId)
  }
  
  static func getInbox(
    byUserId userId: String,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    let url = "\(Constants.Server.stringURL)api/inbox"
    
    var data = [String: Any]()
    data["userId"] = userId
    
    Alamofire
      .request(
        url,
        method: .post,
        parameters: data,
        encoding: JSONEncoding.default
      )
      .validate()
      .responseJSON { (response) in
        var inbox = [[String: Any]]()
        
        switch response.result {
        case .success(let result):
          let result = result as? [String: Any]
          inbox = result?["data"] as? [[String: Any]] ?? inbox
          print(result)
          print(inbox)
        case .failure(let error):
          print(error)
        }
        
        completion(inbox)
    }
  }
  
  static func getOrCreateInboxId(
    fromUserId: String,
    toUserId: String,
    completion: @escaping (String) -> Void
  ) {
    let refFromTo = refInbox
      .child(fromUserId)
      .child(toUserId)
    
    refFromTo.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if let dictionary = snap.value as? [String: Any] {
          if let inboxId = dictionary["inboxId"] as? String {
            completion(inboxId)
          } else {
            completion(refInbox.childByAutoId().key)
          }
        } else {
          completion(refInbox.childByAutoId().key)
        }
      } else {
        completion(refInbox.childByAutoId().key)
      }
    }
  }
  
  static func clearInbox(
    ofUserId: String,
    withUserId: String,
    completion: @escaping () -> Void
  ) {
    var values = [String: Any]()
    values["notifications"] = 0
    
    let refFromTo = refInbox
      .child(ofUserId)
      .child(withUserId)
    
    refFromTo.updateChildValues(values) { (error: Error?, ref: FIRDatabaseReference) in
      completion()
    }
//    refFromTo.updateChildValues(values)
  }
  
  static func createOrUpdateInbox(
    fromUserId: String,
    toUserId: String,
    text: String,
    date: Date,
    inboxId: String,
    completion: (NSError?) -> Void
  ) {
    var valuesFromTo = [String: Any]()
    var valuesToFrom = [String: Any]()
    
    let refFromTo = refInbox
      .child(fromUserId)
      .child(toUserId)
    
    let refToFrom = refInbox
      .child(toUserId)
      .child(fromUserId)
    
    let utc = date.timeIntervalSince1970 * -1
    
    valuesFromTo["text"] = text
    valuesFromTo["dateUpdated"] = utc
    valuesFromTo["anotherUserId"] = toUserId
    valuesFromTo["inboxId"] = inboxId
    
    valuesToFrom["text"] = text
    valuesToFrom["dateUpdated"] = utc
    valuesToFrom["anotherUserId"] = fromUserId
    valuesToFrom["inboxId"] = inboxId
    valuesToFrom["notifications"] = 1
    
    refFromTo.updateChildValues(valuesFromTo)
    refToFrom.updateChildValues(valuesToFrom)
    
    completion(nil)
  }
  
}








































