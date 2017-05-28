//
//  Constants.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/2/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation

struct Constants {
  
  struct Ids {
    static let logoutId = "logoutId"
  }
  
  struct PushNotification {
    static let tradePushNotificationId = "TradePushNotificationId"
    static let chatPushNotificationId = "chatPushNotificationId"
  }
  
  struct Server {
    static var stringURL: String {
//      let url = "http://127.0.0.1:5000/"
      let url = "https://aqueous-river-57184.herokuapp.com/"
//      let url = "http://192.168.1.4:5000/"
      
      return url
    }
  }
  
  struct Instagram {
    private static let clientID = "265265bbe53b4934b9a30ae93597277e"
//    private static let redirectURI = "http://127.0.0.1:5000//instagram-callback"
    private static let redirectURI = "https://aqueous-river-57184.herokuapp.com/instagram-callback"
//    private static let redirectURI = "http://192.168.1.4:5000:5000/instagram-callback"
    
    static var authURL: String {
      let url = "https://api.instagram.com/oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code"
      return url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    static func getURLToGetFirebaseToken(code: String) -> String {
      let url = "\(redirectURI)?code=\(code)"
    
      return url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
  }
  
  struct ErrorMessages {
    
    static let imagesNotTaken = "Please provide at least one picture of your produce."
    static let typeOfProduceNotProvided = "Please choose a category of your produce."
    static let quantityNotProvided = "Please provide quantity of your produce."
    static let priceNotProvided = "Please provide price of your produce."
    static let produceNameNotProvided = "Please provide a name of your produce."
    static let descriptionNotProvided = "Please provide description of your produce."
    
    static let firstNameNotProvided = "Please provide your first name."
    
    static let stateNotSelected = "Please select a state for the produce."
    
    static let unitNotSelected = "Please choose a unit for the produce."
  }
}































