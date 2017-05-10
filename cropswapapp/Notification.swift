//
//  Notification.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/10/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation

struct Notification {
  var dealId: String
  var chat: Int
  var trade: Int
}

extension Notification {
  
  static func listenChatNotifications(
    byUserId userId: String,
    andDealId dealId: String
  ) -> UInt {
    
    return 0
  }
  
  static func listenTradeOrChatNotifications(
    byUserId userId: String,
    andDealId dealId: String
  ) -> UInt {
    
    return 0
  }
  
  static func removeListenTradeOrChatNotifications(
    byUserId userId: String,
    andDealId dealId: String,
    handlerId: UInt
  ) {
    
  }
  
  static func getNotifications(
    byUserId userId: String,
    andDealId dealId: String
  ) {
    
  }
  
  static func createOrUpdateChatNotification(
    withDealId dealId: String,
    andUserId userId: String
  ) {
    
  }
  
  static func createOrUpdateTradeNotification(
    withDealId dealId: String,
    andUserId userId: String
  ) {
    
  }
  
}
