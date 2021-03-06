//
//  Constants.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/2/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
  
  struct Fonts {
    static let montserratBoldFont = UIFont(name: "Montserrat-Semibold", size: 15)
    static let montserratLightFont = UIFont(name: "Montserrat-Light", size: 15)
  }
  
  struct Texts {
    static let writePost = "Write a post..."
    static let writeComment = "Write a comment..."
  }
  
  struct Map {
    static let radius: Int = 1
    static let unitedStatesLat: Double = 39.755769
    static let unitedStatesLng: Double = -100.678711
    
    static let unitedStatesName = "United States"
  }
  
  struct Tag {
    static let tagGroupNames: [String: String] = {
      var values = [String: String]()
      values["habitat"] = "Plant Space"
      values["method"] = "Method"
      values["origin"] = "Origin"
      values["others"] = "Others"
      values["soil-amendments"] = "Soil Amendments"
      return values
    }()
  }
  
  struct Algolia {
    static let searchAPIKey = "df5fa3a6d24e2da4cb02e7a6c65d71a1"
    static let apiID = "LX7ZA23GKW"
  }
  
  struct Ids {
    static let SignupTwoToHome = "SignupTwoToHome"
    
    static let workerId = "worker"
    static let moneyId = "money"
    static let logoutId = "logoutId"
  }
  
  struct PushNotification {
    static let tradePushNotificationId = "TradePushNotificationId"
    static let chatPushNotificationId = "chatPushNotificationId"
    static let requestLocationPushNotificationId = "requestLocationPushNotificationId"
  }
  
  struct Server {
    static var stringURL: String {
//      let url = "http://127.0.0.1:5000/"
//      let url = "https://aqueous-river-57184.herokuapp.com/"
//      let url = "http://localhost:5000/cropswap-60191/us-central1/app/"
//       let url = "http://6efe4d52.ngrok.io/cropswap-60191/us-central1/app/"
      let url = "https://us-central1-cropswap-60191.cloudfunctions.net/app/"
//      let url = "http://192.168.1.6:5000/"
      
      return url
    }
  }
  
  struct Instagram {
    private static let clientID = "265265bbe53b4934b9a30ae93597277e"
    //    private static let redirectURI = "http://127.0.0.1:5000//instagram-callback"
    //    private static let redirectURI = "https://aqueous-river-57184.herokuapp.com/instagram-callback"
    //    private static let redirectURI = "http://192.168.1.6:5000:5000/instagram-callback"
    private static let redirectURI = "https://us-central1-cropswap-60191.cloudfunctions.net/app/instagram-callback"
    
    static var authURL: String {
      let url = "https://api.instagram.com/oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code"
      return url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    static func getURLToGetFirebaseToken(code: String) -> String {
      let url = "\(redirectURI)?code=\(code)"
    
      return url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    static func getURLToGetUserMedia(
      instagramClientId: String, // 3616078780
      instagramAccessToken: String // 3616078780.265265b.1357b89a8b2a4e3db7a975441db31fac
    ) -> String {
      return "https://api.instagram.com/v1/users/\(instagramClientId)/media/recent/?access_token=\(instagramAccessToken)"
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
    static let usernameNotProvided = "Please provide your username."
    
    static let stateNotSelected = "Please select a state for the produce."
    
    static let unitNotSelected = "Please choose a unit for the produce."
  }
}































