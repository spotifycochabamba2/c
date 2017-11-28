//
//  Notification.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/10/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Ax
import Alamofire
import SwiftyJSON

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
  static let refDatabase = CSFirebase.refDatabase
  static let refDatabaseNotifications = refDatabase.child("notifications")
  
  static var refDatabaseUserDeals = refDatabase.child("deals-by-user")
  static var refDatabaseInbox = refDatabase.child("inbox")
  
  static func getNotificationsForAppIcon(
    userId: String,
    completion: @escaping (NSError?, Int) -> Void
  ) {
    let url = "\(Constants.Server.stringURL)api/notifications"
    var data = [String: Any]()
    data["userId"] = userId
    
    var userToken: String?
    var counter = 0
    
    Ax.serial(tasks: [
      
      { done in
        if let user = FIRAuth.auth()?.currentUser {
          user.getTokenForcingRefresh(true, completion: { (token, error) in
            userToken = token
            done(error as NSError?)
          })
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      },
      
      { done in
        if let token = userToken {
          let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
          ]
          
          Alamofire
            .request(
              url,
              method: .post,
              parameters: data,
              encoding: JSONEncoding.default,
              headers: headers
            )
            .validate()
            .responseJSON { (response) in
              switch response.result {
              case .success(let result):
                let result = result as? [String: Any]
                counter = result?["counter"] as? Int ?? 0
                done(nil)
              case .failure(let error):
                done(error as NSError?)
              }
          }
        } else {
          let error = NSError(
            domain: "Notifications",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      }
      
    ]) { (error) in
      completion(error, counter)
    }
  }
  
  static func saveOrUpdateTradeNotification(
    byUserId userId: String,
    dealId: String,
    field: String, // chat or trade
    withValue value: Int,
    completion: @escaping (NSError?) -> Void
  ) -> Void {
    
    let refDatabaseUserNotification = refDatabaseNotifications
                                        .child(userId)
                                        .child(dealId)
    var values = [String: Any]()
    values[field] = value
    
    refDatabaseUserNotification.updateChildValues(values) { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as NSError?)
    }
  }
  
  static func listenTradeNotifications(
    byUserId userId: String,
    completion: @escaping (Int) -> Void
  ) -> UInt {
    let refDatabaseUserNotification = refDatabaseNotifications
                                      .child(userId)
    
    return refDatabaseUserNotification.observe(.value) { (snap: FIRDataSnapshot) in
      var totalTradeNotifications = 0
      
      if snap.exists() {

        if let children = snap.children.allObjects as? [FIRDataSnapshot] {
          
          for dictionary in children {
            if let child = dictionary.value as? [String: Any] {
              let chat = child["chat"] as? Int ?? 0
              let trade = child["trade"] as? Int ?? 0
              
              let value = (chat + trade) > 0 ? 1 : 0
              
              totalTradeNotifications += value
            }
          }
        }
        
      }
      
      completion(totalTradeNotifications)
    }
  }
  
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
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification.child(dealId)
    
    var values = [String: Any]()
    values["chat"] = 0
    
    saveOrUpdateTradeNotification(
      byUserId: userId,
      dealId: dealId,
      field: "chat",
      withValue: 0
    ) { (error) in

    }
    
    refDatabaseNotificationUser.updateChildValues(values, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as? NSError)
    })
  }
  
//  static func saveOrUpdateInboxNotification(
//    fromUserId: String,
//    toUserId: String
//  ) {
//    
//  }
  
  static func createOrUpdateChatNotification(
    withDealId dealId: String,
    andUserId userId: String,
    completion: @escaping (NSError?) -> Void
  ) {
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
    let refDatabaseNotification = refDatabaseUserDeals.child(userId)
    let refDatabaseNotificationUser = refDatabaseNotification.child(dealId)
    
    var values = [String: Any]()
    values["trade"] = 0
    
    saveOrUpdateTradeNotification(
      byUserId: userId,
      dealId: dealId,
      field: "trade",
      withValue: 0
    ) { (error) in
    }
    
    refDatabaseNotificationUser.updateChildValues(values, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as? NSError)
    })
  }
  
  static func createOrUpdateTradeNotification(
    withDealId dealId: String,
    andUserId userId: String,
    completion: @escaping (NSError?) -> Void
  ) {
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





























 
