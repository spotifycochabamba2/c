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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var isTerminatedState = false


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    
    // Override point for customization after application launch.
    FIRApp.configure()
//    FIRDatabase.database().persistenceEnabled = true
    
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
  
  func handlePushNotificationForSavingInUserDefault(_ userInfo: [String: Any]?) {
    if
      let userInfo = userInfo
    {
      
      if let _ = userInfo["isChatNotification"] as? String {
        saveInUserDefaultsAboutNewMessagePushNotificationFromTerminatedState(userInfo)
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
  
  func saveInUserDefaultsAboutNewTradePushNotificationFromTerminatedState(
    _ userInfo: [String: Any]
  ) {
    if
      let dealId = userInfo["dealId"] as? String,
      let ownerUserId = userInfo["ownerUserId"] as? String,
      let dealState = userInfo["dealState"] as? String,
      let ownerUsername = userInfo["ownerUsername"] as? String
    {
      let defaults = UserDefaults.standard
      defaults.set(dealId, forKey: "dealId")
      defaults.set(ownerUserId, forKey: "ownerUserId")
      defaults.set(dealState, forKey: "dealState")
      defaults.set(ownerUsername, forKey: "ownerUsername")
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
//      print("belanova from requestAuthorization")
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
    print(notification.request.content.userInfo)
    let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController

    if let tradeChatVC = rootVC?.visibleViewController as? TradeChatVC {
      if
        let userInfo = notification.request.content.userInfo as? [String: Any],
        let _ = userInfo["isChatNotification"] as? String,
        let dealId = userInfo["dealId"] as? String
      {
        print(tradeChatVC.dealId)
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
//    print("belanova from tokenRefreshNotification")
//    registerDeviceToken()
//  }
//  
//  func registerDeviceToken() {
//    print("belanova from registerDeviceToken \(FIRInstanceID.instanceID().token())")
//  }
  
  func handlePushNotification(userInfo: [String: Any]?) {
    if let userInfo = userInfo {
      
      print(userInfo)
      if let _ = userInfo["isChatNotification"] as? String {
        notifyChatPushNotification(userInfo: userInfo)
      } else {
        notifyTradePushNotification(userInfo: userInfo)
      }
      
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
      let ownerUsername = userInfo["ownerUsername"] as? String
    {
      var data = [String: Any]()
      data["dealId"] = dealId
      data["ownerUserId"] = ownerUserId
      data["dealState"] = dealState
      data["ownerUsername"] = ownerUsername
      
      NotificationCenter.default.post(name: Notification.Name(Constants.PushNotification.tradePushNotificationId), object: data)
    }
  }
}





































