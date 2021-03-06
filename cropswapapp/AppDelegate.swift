//
//  AppDelegate.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/25/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var isTerminatedState = false


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    
    // Override point for customization after application launch.
    FIRApp.configure()
//    FIRDatabase.database().persistenceEnabled = true
    
    logoutIfFirstTimeUse()
    
    configurePushNotifications(application)
    
//    NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshNotification(notification:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
    
    let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
    if let userInfo = notification as? [String: Any] {
      isTerminatedState = true
      handlePushNotificationForSavingInUserDefault(userInfo)
//      saveInUserDefaultsAboutNewTradePushNotificationFromTerminatedState(userInfo)
    }
    
    return true
  }
  
  func logoutIfFirstTimeUse() {
    let userDefaults = UserDefaults.standard
    
    if !userDefaults.bool(forKey: "hasRunBefore") {
      do {
        try FIRAuth.auth()?.signOut()
      } catch {
        
      }
      
      userDefaults.set(true, forKey: "hasRunBefore")
      userDefaults.synchronize()
    }
  }
  
  func handlePushNotificationForSavingInUserDefault(_ userInfo: [String: Any]?) {
    if
      let userInfo = userInfo
    {
      
      if let _ = userInfo["isChatNotification"] as? String {
        saveInUserDefaultsAboutNewMessagePushNotificationFromTerminatedState(userInfo)
      } else if let _ = userInfo["isRequestLocationNotification"] as? String  {
        saveInUserDefaultsAboutRequestLocationPushNotificationFromTerminatedState(userInfo)
      } else {
        saveInUserDefaultsAboutNewTradePushNotificationFromTerminatedState(userInfo)
      }
    }
  }
  
  func saveInUserDefaultsAboutNewMessagePushNotificationFromTerminatedState(_ userInfo: [String: Any]) {
    if
      let dealId = userInfo["dealId"] as? String,
      let senderId = userInfo["senderId"] as? String,
      let senderUsername = userInfo["senderUsername"] as? String
    {
      let defaults = UserDefaults.standard
      defaults.set(true, forKey: "isChatNotification")
      defaults.set(dealId, forKey: "dealId")
      defaults.set(senderId, forKey: "senderId")
      defaults.set(senderUsername, forKey: "senderUsername")
      defaults.synchronize()
    }
  }
  
  func saveInUserDefaultsAboutRequestLocationPushNotificationFromTerminatedState(
    _ userInfo: [String: Any]
  ) {
    if
      let dealString = userInfo["deal"] as? String
    {
      let dealJSON = JSON(parseJSON: dealString)
      
      let defaults = UserDefaults.standard
      defaults.set(dealJSON.dictionaryObject, forKey: "deal")
      defaults.set(true, forKey: "isRequestLocationNotification")
      defaults.synchronize()
    }
  }
  
  func saveInUserDefaultsAboutNewTradePushNotificationFromTerminatedState(
    _ userInfo: [String: Any]
  ) {
    if
      let dealId = userInfo["dealId"] as? String,
      let ownerUserId = userInfo["ownerUserId"] as? String,
      let dealState = userInfo["dealState"] as? String,
      let ownerUsername = userInfo["ownerUsername"] as? String,
      let originalOwnerUserId = userInfo["originalOwnerUserId"] as? String,
      let originalOwnerProducesCount = userInfo["originalOwnerProducesCount"] as? String,
      let originalAnotherProducesCount = userInfo["originalAnotherProducesCount"] as? String
    {
      let defaults = UserDefaults.standard
      defaults.set(dealId, forKey: "dealId")
      defaults.set(ownerUserId, forKey: "ownerUserId")
      defaults.set(dealState, forKey: "dealState")
      defaults.set(ownerUsername, forKey: "ownerUsername")
      defaults.set(originalOwnerUserId, forKey: "originalOwnerUserId")
      defaults.set(Int(originalOwnerProducesCount) ?? 0, forKey: "originalOwnerProducesCount")
      defaults.set(Int(originalAnotherProducesCount) ?? 0, forKey: "originalAnotherProducesCount")
      defaults.synchronize()
    }
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}


extension AppDelegate: UNUserNotificationCenterDelegate, FIRMessagingDelegate {
  func configurePushNotifications(_ application: UIApplication) {
    
    // APNS
    UNUserNotificationCenter.current().delegate = self
//    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//    UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { [weak self] (_, _) in
//      self?.registerDeviceToken()
//    })
    
    // FCM
    FIRMessaging.messaging().remoteMessageDelegate = self
    
    application.registerForRemoteNotifications()
  }
  
  func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {

  }
  
  // background, terminated
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if !isTerminatedState {
      handlePushNotification(userInfo: response.notification.request.content.userInfo as? [String: Any])
//      notifyTradePushtNotification(userInfo: response.notification.request.content.userInfo as? [String: Any])
    } else {
      isTerminatedState = false
    }
  }
  
  // foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController

    if let tradeChatVC = rootVC?.visibleViewController as? TradeChatVC {
      if
        let userInfo = notification.request.content.userInfo as? [String: Any],
        let _ = userInfo["isChatNotification"] as? String,
        let dealId = userInfo["dealId"] as? String
      {
        if tradeChatVC.dealId == dealId {
          // don't show the remote notification
        } else {
          completionHandler(.alert)
        }
      } else {
        completionHandler(.alert)
      }
    } else {
      completionHandler(.alert)
    }
  }
  
//  func tokenRefreshNotification(notification: NSNotification) {
//    registerDeviceToken()
//  }
//  
//  func registerDeviceToken() {
//  }
  
  func handlePushNotification(userInfo: [String: Any]?) {
    if let userInfo = userInfo {
      if let _ = userInfo["isChatNotification"] as? String {
        notifyChatPushNotification(userInfo: userInfo)
      } else if let _ = userInfo["isRequestLocationNotification"] as? String {
        notifyRequestLocationPushNotification(userInfo: userInfo)
      } else {
        notifyTradePushNotification(userInfo: userInfo)
      }
      
    }
  }
  
  func notifyRequestLocationPushNotification(userInfo: [String: Any]) {
    if
      let dealString = userInfo["deal"] as? String
    {
      let dealJSON = JSON(parseJSON: dealString)
      
      var data = [String: Any]()
      data["deal"] = dealJSON.dictionaryObject
      
      NotificationCenter.default.post(
        name: Notification.Name(Constants.PushNotification.requestLocationPushNotificationId),
        object: data
      )
    }
  }
  
  func notifyChatPushNotification(userInfo: [String: Any]) {
    if
      let dealId = userInfo["dealId"] as? String,
      let senderId = userInfo["senderId"] as? String,
      let senderUsername = userInfo["senderUsername"] as? String
    {
      var data = [String: Any]()
      data["dealId"] = dealId
      data["senderId"] = senderId
      data["senderUsername"] = senderUsername
      data["isChatNotification"] = true
      
      NotificationCenter.default.post(
        name: Notification.Name(Constants.PushNotification.chatPushNotificationId),
        object: data
      )
    }
  }
  
  func notifyTradePushNotification(userInfo: [String: Any]) {
    if
      let dealId = userInfo["dealId"] as? String,
      let ownerUserId = userInfo["ownerUserId"] as? String,
      let dealState = userInfo["dealState"] as? String,
      let ownerUsername = userInfo["ownerUsername"] as? String,
      let originalOwnerUserId = userInfo["originalOwnerUserId"] as? String,
      let originalOwnerProducesCount = userInfo["originalOwnerProducesCount"] as? String,
      let originalAnotherProducesCount = userInfo["originalAnotherProducesCount"] as? String
    {
      var data = [String: Any]()
      data["dealId"] = dealId
      data["ownerUserId"] = ownerUserId
      data["dealState"] = dealState
      data["ownerUsername"] = ownerUsername
      data["originalOwnerUserId"] = originalOwnerUserId
      data["originalOwnerProducesCount"] = Int(originalOwnerProducesCount) ?? 0
      data["originalAnotherProducesCount"] = Int(originalAnotherProducesCount) ?? 0
      
      NotificationCenter.default.post(name: Notification.Name(Constants.PushNotification.tradePushNotificationId), object: data)
    }
  }
}





































