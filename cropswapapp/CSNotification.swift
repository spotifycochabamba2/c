//
//  Notification.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/10/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Ax

struct CSNotification {
  var dealId: String?
  var chat: Int
  var trade: Int?
  
  init?(chat: Int?) {
    guard
       let chat = chat
    else {
      return nil
    }
    
    self.chat = chat
    self.trade = 0
  }
  
  init() {
    self.chat = 0
    self.trade = 0
  }
}

extension CSNotification {
  static let refDatabase = FIRDatabase.database().reference()
  static let refDatabaseNotifications = refDatabase.child("notifications")
  static var refDatabaseUserDeals = refDatabase.child("deals-by-user")
  
  static func listenChatNotifications(
    byUserId userId: String,
    andDealId dealId: String,
    completion: @escaping (CSNotification) -> Void
  ) -> UInt {
    
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification
                                          .child(dealId)
                                          .child("chat")
    
//    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
//    let refDatabaseNotificationUser = refDatabaseNotification
//                                              .child(userId)
//                                              .child("chat")
    print(refDatabaseNotificationUser.url)
    
    return refDatabaseNotificationUser.observe(.value, with: { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if
          let notification = CSNotification(chat: snap.value as? Int)
        {
          completion(notification)
        }
      }
    })
  }
  
  //not applied
//  static func listenTradeOrChatNotifications(
//    byUserId userId: String,
//    andDealId dealId: String,
//    completion: @escaping (CSNotification) -> Void
//  ) -> UInt {
////    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
////    let refDatabaseNotificationUser = refDatabaseNotification.child(userId)
//    
//    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
//    let refDatabaseNotificationUser = refDatabaseNotification.child(dealId)
//    
//    return refDatabaseNotificationUser.observe(.childChanged, with: { (snap: FIRDataSnapshot) in
//      if snap.exists() {
//        if
//          let notification = CSNotification(json: snap.value as? [String: Any])
//        {
//          completion(notification)
//        }
//      }
//    })
//  }
  
  //not applied
  static func removeListenChatNotifications(
    byUserId userId: String,
    andDealId dealId: String,
    handlerId: UInt
  ) {
    
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification
      .child(dealId)
      .child("chat")
    
//    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
//    let refDatabaseNotificationUser = refDatabaseNotification
//      .child(userId)
//      .child("chat")
    
    refDatabaseNotificationUser.removeObserver(withHandle: handlerId)
  }
  
  //not applied
  static func removeListenTradeOrChatNotifications(
    byUserId userId: String,
    andDealId dealId: String,
    handlerId: UInt
  ) {
    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
    let refDatabaseNotificationUser = refDatabaseNotification.child(userId)
    
    refDatabaseNotificationUser.removeObserver(withHandle: handlerId)
  }
  
  
//  //not applied
//  static func getNotification(
//    byUserId userId: String,
//    andDealId dealId: String,
//    completion: @escaping (CSNotification) -> Void
//  ) {
//    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
//    let refDatabaseNotificationUser = refDatabaseNotification.child(userId)
//    
//    refDatabaseNotificationUser.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
//      if let notification = CSNotification(json: snap.value as? [String: Any]) {
//        completion(notification)
//      } else {
//        completion(CSNotification())
//      }
//    }
//  }
  
  static func clearChatNotification(
    withDealId dealId: String,
    andUserId userId: String,
    completion: @escaping (NSError?) -> Void
  ) {
//    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
//    let refDatabaseNotificationUser = refDatabaseNotification.child(userId)
    
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification.child(dealId)
    
    var values = [String: Any]()
    values["chat"] = 0
    
    refDatabaseNotificationUser.updateChildValues(values, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as? NSError)
    })
  }
  
  static func createOrUpdateChatNotification(
    withDealId dealId: String,
    andUserId userId: String,
    completion: @escaping (NSError?) -> Void
  ) {
//    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
//    let refDatabaseNotificationUser = refDatabaseNotification.child(userId)
    
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification.child(dealId)
    
    refDatabaseNotificationUser.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
      
      if var notification = currentData.value as? [String: Any] {
        var chat = notification["chat"] as? Int ?? 0
        chat += 1
        
        notification["chat"] = chat as AnyObject?
        
        currentData.value = notification
        return FIRTransactionResult.success(withValue: currentData)
      } else {
//        var values = [String: Any]()
//        values["chat"] = 1
//        
//        currentData.value = values
        return FIRTransactionResult.success(withValue: currentData)
      }
    }) { (error, commited, snap) in
      completion(error as NSError?)
    }
  }
  
  
  
  static func clearTradeNotification(
    withDealId dealId: String,
    andUserId userId: String,
    completion: @escaping (NSError?) -> Void
  ) {
//    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
//    let refDatabaseNotificationUser = refDatabaseNotification.child(userId)
    
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification.child(dealId)
    
    var values = [String: Any]()
    values["trade"] = 0
    
    refDatabaseNotificationUser.updateChildValues(values, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as? NSError)
    })
  }
  
  static func createOrUpdateTradeNotification(
    withDealId dealId: String,
    andUserId userId: String,
    completion: @escaping (NSError?) -> Void
  ) {
//    let refDatabaseNotification = refDatabaseNotifications.child(dealId)
//    let refDatabaseNotificationUser = refDatabaseNotification.child(userId)
    
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification.child(dealId)
    
    
    var values = [String: Any]()
    values["trade"] = 1
    
    refDatabaseNotificationUser.updateChildValues(
      values,
      withCompletionBlock: {(error: Error?, ref: FIRDatabaseReference) in
        completion(error as? NSError)
    })
  }
}





























 
