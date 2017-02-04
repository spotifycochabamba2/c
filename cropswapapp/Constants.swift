//
//  Constants.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/2/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation

struct Constants {
  struct Instagram {
    private static let clientID = "265265bbe53b4934b9a30ae93597277e"
    // http://192.168.0.101:5000/instagram-callback
    // https://aqueous-river-57184.herokuapp.com/instagram-callback
    private static let redirectURI = "http://192.168.0.101:5000/instagram-callback"
    
    static var authURL: String {
      let url = "https://api.instagram.com/oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code"
      return url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
  }
}
