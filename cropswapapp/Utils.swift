//
//  Utils.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import Ax
import CoreLocation
import UIKit

struct Utils {
  
  static let usernameFont: UIFont = {
    return UIFont(name: "Montserrat-SemiBold", size: 17)
  }()!
  
  static let dateFont: UIFont = {
    return UIFont(name: "Montserrat-Regular", size: 13)
  }()!
  
  static let textFont: UIFont = {
    return UIFont(name: "Montserrat-Regular", size: 15)
  }()!
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    
    formatter.dateFormat = "MM/dd/yyyy"
    
    return formatter
  }()
  
  static func relativePast(for date : Date) -> String {
    
    let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
    let components = Calendar.current.dateComponents(units, from: date, to: Date())
    
    if components.year! > 0 {
      return "\(components.year!) " + (components.year! > 1 ? "years ago" : "year ago")
      
    } else if components.month! > 0 {
      return "\(components.month!) " + (components.month! > 1 ? "months ago" : "month ago")
      
    } else if components.weekOfYear! > 0 {
      return "\(components.weekOfYear!) " + (components.weekOfYear! > 1 ? "weeks ago" : "week ago")
      
    } else if (components.day! > 0) {
      return (components.day! > 1 ? "\(components.day!) days ago" : "Yesterday")
      
    } else if components.hour! > 0 {
      return "\(components.hour!) " + (components.hour! > 1 ? "hours ago" : "hour ago")
      
    } else if components.minute! > 0 {
      return "\(components.minute!) " + (components.minute! > 1 ? "minutes ago" : "minute ago")
      
    } else {
      return "\(components.second!) " + (components.second! > 1 ? "seconds ago" : "second ago")
    }
  }
  
  
  static func getDistanceInKM(
    fromLatitude: Double,
    fromLongitude: Double,
    toLatitude: Double,
    toLongitude: Double
  ) -> Double {
    
    let fromCoordinate = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
    let toCoordinate = CLLocation(latitude: toLatitude, longitude: toLongitude)
    
    return fromCoordinate.distance(from: toCoordinate) * 0.000621371192
//        return round(fromCoordinate.distance(from: toCoordinate) * 0.001)
  }
  
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





























