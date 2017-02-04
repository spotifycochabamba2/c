//
//  Utils.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation

struct Utils {
  static func getQueryStringParameter(url: URL?, param: String) -> String? {
    
    guard let url = url else { return nil }
    
    if
      let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
      let queryItems = components.queryItems
    {
      return queryItems.filter { $0.name == param }.first?.value
    }
    
    return nil
  }
  
}
