//
//  HomeTBC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class HomeTBC: UITabBarController {
  
  var label = UILabel(frame: CGRect(x: 10, y: -10, width: 20, height: 20))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    label.layer.borderColor = UIColor.clear.cgColor
    label.layer.borderWidth = 2
    label.layer.cornerRadius = label.bounds.size.height / 2
    label.textAlignment = .center
    label.layer.masksToBounds = true
    label.font = UIFont(name: "Montserrat-Light", size: 13)
    label.textColor = .white
    label.backgroundColor = UIColor.red
    label.text = "80"
    
    let tradeListTabBarItem = tabBar.items?[1]
    
    print(tradeListTabBarItem)
    
    let tabBarFont = UIFont(name: "Montserrat-Light", size: 13)
    
    let tabBarAttributesDictionary: [String: AnyObject]? = [
      NSForegroundColorAttributeName: UIColor.white,
      NSFontAttributeName: tabBarFont!
    ]
    
    tradeListTabBarItem?.setBadgeTextAttributes(tabBarAttributesDictionary, for: .normal)
    
    navigationBarIsHidden = true
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { [weak self] (_, _) in
      print("belanova from requestAuthorization")
      self?.registerDeviceToken()
    })
    
    NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshNotification(notification:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
    
    let defaults = UserDefaults.standard
    
    if let isChatNotification = defaults.object(forKey: "isChatNotification") as? Bool,
        isChatNotification
    {
      if
        let dealId = defaults.object(forKey: "dealId") as? String,
        let senderId = defaults.object(forKey: "senderId") as? String,
        let senderUsername = defaults.object(forKey: "senderUsername") as? String
      {
        var data = [String: Any]()
        data["dealId"] = dealId
        data["senderId"] = senderId
        data["senderUsername"] = senderUsername
        showChat(data)
        
        defaults.set(nil, forKey: "dealId")
        defaults.set(nil, forKey: "senderId")
        defaults.set(nil, forKey: "senderUsername")
        defaults.set(nil, forKey: "isChatNotification")
        defaults.synchronize()
      }
    } else {
      if
        let dealId = defaults.object(forKey: "dealId") as? String,
        let ownerUserId = defaults.object(forKey: "ownerUserId") as? String,
        let ownerUsername = defaults.object(forKey: "ownerUsername") as? String,
        let dealState = defaults.object(forKey: "dealState") as? String,
        let originalOwnerUserId = defaults.object(forKey: "originalOwnerUserId") as? String,
        let originalOwnerProducesCount = defaults.object(forKey: "originalOwnerProducesCount") as? Int,
        let originalAnotherProducesCount = defaults.object(forKey: "originalAnotherProducesCount") as? Int
      {
        var data = [String: Any]()
        data["dealId"] = dealId
        data["ownerUserId"] = ownerUserId
        data["ownerUsername"] = ownerUsername
        data["dealState"] = dealState
        data["originalOwnerUserId"] = originalOwnerUserId
        data["originalOwnerProducesCount"] = originalOwnerProducesCount
        data["originalAnotherProducesCount"] = originalAnotherProducesCount
        showTradeDetail(data)
        
        defaults.set(nil, forKey: "dealId")
        defaults.set(nil, forKey: "ownerUserId")
        defaults.set(nil, forKey: "ownerUsername")
        defaults.set(nil, forKey: "dealState")
        defaults.set(nil, forKey: "originalOwnerUserId")
        defaults.set(nil, forKey: "originalOwnerProducesCount")
        defaults.set(nil, forKey: "originalAnotherProducesCount")
        defaults.synchronize()
      }
    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(logoutNotification),
      name: Notification.Name(Constants.Ids.logoutId),
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(tradePushNotificationGot),
      name: Notification.Name(Constants.PushNotification.tradePushNotificationId),
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(chatPushNotificationGot),
      name: Notification.Name(Constants.PushNotification.chatPushNotificationId),
      object: nil)
    
    UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.monserratFont(type: "Regular", size: 9), NSForegroundColorAttributeName: UIColor.cropswapRed], for: .normal)
    
    tabBar.tintColor = UIColor.cropswapRed
    tabBar.unselectedItemTintColor = UIColor.hexStringToUIColor(hex: "#bbbbbb")
    tabBar.barTintColor = .white
    tabBar.isTranslucent = true
    
    if let userId = User.currentUser?.uid {
      _ = CSNotification.listenTradeNotifications(byUserId: userId, completion: { (counter) in
        DispatchQueue.main.async {
          if counter <= 0 {
            tradeListTabBarItem?.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
          } else {
            tradeListTabBarItem?.badgeValue = "\(counter)"
            UIApplication.shared.applicationIconBadgeNumber = counter
          }
        }
      })
    }
  }
  
  func logoutNotification() {
    User.logout()
    
    _ = navigationController?.popToRootViewController(animated: true)
  }
  
  func tokenRefreshNotification(notification: NSNotification) {
    print("belanova from tokenRefreshNotification")
    registerDeviceToken()
  }
  
  func registerDeviceToken() {
    print("belanova from registerDeviceToken \(FIRInstanceID.instanceID().token())")
    
    if
      let deviceToken = FIRInstanceID.instanceID().token(),
      let userId = User.currentUser?.uid {
      User.updateUser(byId: userId, deviceToken: deviceToken, completion: { (error) in
        print(error)
      })
    }
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.PushNotification.tradePushNotificationId), object: nil)
  }
  
  func tradePushNotificationGot(notification: Notification) {
    print(notification.object)
    
    if let data = notification.object as? [String: Any] {
      showTradeDetail(data)
    }
  }
  
  func chatPushNotificationGot(notification: Notification) {
    print(notification.object)
    
    if let data = notification.object as? [String: Any] {
      showChat(data)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.HomeToTradeHome {
      let nv = segue.destination as? UINavigationController
      print(nv)
      let vc = nv?.viewControllers.first as? TradeHomeVC
      print(vc)
      let data = sender as? [String: Any]
      print(data)
      
      vc?.originalOwnerUserId = data?["originalOwnerUserId"] as? String
      vc?.originalOwnerProducesCount = data?["originalOwnerProducesCount"] as? Int ?? 0
      vc?.originalAnotherProducesCount = data?["originalAnotherProducesCount"] as? Int ?? 0
      vc?.dealId = data?["dealId"] as? String
      vc?.anotherUserId = data?["ownerUserId"] as? String
      vc?.dealState = DealState(rawValue: data?["state"] as? String ?? DealState.tradeRequest.rawValue)
      vc?.anotherUsername = data?["ownerUsername"] as? String
    } else if segue.identifier == Storyboard.HomeToTradeChat {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TradeChatVC
      
      let data = sender as? [String: Any]
      
      vc?.anotherUserId = data?["senderId"] as? String
      vc?.anotherUsername = data?["senderUsername"] as? String
      vc?.dealId = data?["dealId"] as? String
    }
  }
  
  func showChat(_ data: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
//      self?.performSegue(withIdentifier: Storyboard.HomeToTradeChat, sender: data)
      
      let storyboard = UIStoryboard(name: "TradeDetail", bundle: nil)
      let ncTradeChatVC = storyboard.instantiateViewController(withIdentifier: "NCTradeChatVC") as? UINavigationController
      print(ncTradeChatVC)
      let vc = ncTradeChatVC?.viewControllers.first as? TradeChatVC
      print(vc)
//      let data = sender as? [String: Any]
      
      vc?.anotherUserId = data["senderId"] as? String
      vc?.anotherUsername = data["senderUsername"] as? String
      vc?.dealId = data["dealId"] as? String
      
      if let ncTradeChatVC = ncTradeChatVC {
//        self?.present(ncTradeChatVC, animated: true)
        print(self)

        let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController
        print(rootVC?.visibleViewController);
        
        rootVC?.visibleViewController?.present(ncTradeChatVC, animated: true)
      }
    }
  }
  
  func showTradeDetail(_ data: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.performSegue(withIdentifier: Storyboard.HomeToTradeHome, sender: data)
    }
  }
  
}





























