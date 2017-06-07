//
//  Message.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Ax
import Alamofire

struct Message {
  var senderId: String
  var text: String
  var dateCreated: Date
  var id: String = ""
  
  init(
    senderId: String,
    text: String,
    dateCreated: Date
  ) {
    self.senderId = senderId
    self.text = text
    self.dateCreated = dateCreated
  }
  
  init?(json: [String: Any]?) {
    guard
      let json = json,
      let senderId = json["senderId"] as? String,
      let text = json["text"] as? String,
      let utcDate = json["dateCreated"] as? Double,
      let id = json["id"] as? String
      else {
        return nil
    }
    
    self.senderId = senderId
    self.text = text
    self.dateCreated = Date(timeIntervalSince1970: (utcDate * -1))
    self.id = id
  }
}

extension Message {
  static let refDatabase = CSFirebase.refDatabase
  static let refChat = refDatabase.child("chat")
  
  
  static let refMessages = refDatabase.child("messages")
  
  
  static func sendMessage(
    dealId: String,
    senderId: String,
    receiverId: String,
    text: String,
    date: Date,
    completion: @escaping (NSError?) -> Void
  ) -> String {
    let refDealMessage = refMessages.child(dealId).childByAutoId()
    let messageId = refDealMessage.key
    
    var data = [String: Any]()
    data["id"] = messageId
    data["senderId"] = senderId
    data["text"] = text
    data["dateCreated"] = date.timeIntervalSince1970 * -1
    
    refDealMessage.setValue(data, withCompletionBlock: {
      (error: Error?, ref: FIRDatabaseReference) in
      
//      sendMessagePushNotification(
//        dealId: dealId,
//        senderId: senderId,
//        receiverId: receiverId,
//        text: text,
//        completion: { (_) in
//          
//      })
//      
//      CSNotification.createOrUpdateChatNotification(
//        withDealId: dealId,
//        andUserId: receiverId,
//        completion: { (error) in
//          print(error)
//        }
//      )
//      
//      CSNotification.saveOrUpdateTradeNotification(
//        byUserId: receiverId,
//        dealId: dealId,
//        field: "chat",
//        withValue: 1,
//        completion: { (error) in
//          print(error)
//      })
      
      completion(error as NSError?)
    })
    
    return messageId
  }
  
  static func sendMessagePushNotification(
    dealId: String,
    senderId: String,
    receiverId: String,
    text: String,
    completion: @escaping (NSError?) -> Void
  ) {
    let url = "\(Constants.Server.stringURL)send-chat-push"
    
    var data = [String: Any]()
    data["dealId"] = dealId
    data["senderId"] = senderId
    data["receiverId"] = receiverId
    data["message"] = text
    
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
        case .success(_):
          completion(nil)
        case .failure(let error):
          completion(error as NSError?)
        }
    }
  }
  
  static func getMessages(
    byDealId dealId: String,
    completion: @escaping ([Message]) -> Void
  ) {
    let refDealMessages = refMessages.child(dealId)
    
    refDealMessages.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      var messages = [Message]()
      
      if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
        messages = dictionaries.flatMap {
          return Message(json: $0.value as? [String: Any])
        }
      }
      
      completion(messages)
    }
  }
  
  static func listenNewMessages(
    byDealId dealId: String,
    date: Date,
    completion: @escaping (Message) -> Void
  ) -> UInt {
    let utcDate = date.timeIntervalSince1970 * -1
    
    let refDealMessages = refMessages
                          .child(dealId)
                          .queryOrdered(byChild: "dateCreated")
                          .queryEnding(atValue: utcDate)
    
    return refDealMessages.observe(.childAdded) { (snap: FIRDataSnapshot) in
      if let message = Message(json: snap.value as? [String: Any]) {
        completion(message)
      }
    }
  }
  
  static func removeListenNewMessages(
    byDealId dealId: String,
    date: Date,
    handlerId: UInt
  ) {
    let refDealMessages = refMessages.child(dealId)
    
    refDealMessages.removeObserver(withHandle: handlerId)
  }
  
  
//  static func getMessages(completion: @escaping ([Message]) -> Void) {
//    //    let refChatDesc = refChat.queryOrdered(byChild: "timestamp")
//    
//    refChat.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
//      var messages = [Message]()
//      
//      if snap.exists() {
//        if let dictionary = snap.children.allObjects as? [FIRDataSnapshot] {
//          
//          messages = dictionary.flatMap { Message(json: $0.value as? [String: Any]) }
//          
//        }
//      }
//      completion(messages)
//    }
//  }
//  
//  static func removeListenNewMessages(fromTime time: Date, handlerId: UInt) {
//    let timestamp = 0 - (time.timeIntervalSince1970 * 1000)
//    
//    refChat
//      .queryOrdered(byChild: "timestamp")
//      .queryEnding(atValue: timestamp)
//      .removeObserver(withHandle: handlerId)
//  }
//  
//  static func listenNewMessages(fromTime time: Date, completion: @escaping (Message) -> Void) -> UInt {
//    let timestamp = 0 - (time.timeIntervalSince1970 * 1000)
//    print(timestamp)
//    let query = refChat
//      .queryOrdered(byChild: "timestamp")
//      .queryEnding(atValue: timestamp)
//    
//    return query.observe(.childAdded) { (snap: FIRDataSnapshot) in
//      if snap.exists() {
//        if let message = Message(json: snap.value as? [String: Any]) {
//          completion(message)
//        }
//      }
//    }
//  }

//  static func sendMessage(_ message: Message, completion: @escaping (NSError?) -> Void) {
//    
//    let refMessage = refChat.childByAutoId()
//    let currentDateUTC = message.date.timeIntervalSince1970
//    
//    var data = [String: Any]()
//    data["senderId"] = message.senderId
//    data["username"] = message.username
//    data["text"] = message.text
//    data["imageURL"] = message.imageURL ?? ""
//    
//    // used for purposes of sorting in desc order
//    //http://stackoverflow.com/questions/36589452/in-firebase-how-can-i-query-the-most-recent-10-child-nodes
//    data["timestamp"] = 0 - (currentDateUTC * 1000)
//    
//    refMessage.setValue(data, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
//      completion(error as NSError?)
//    })
//  }
}































