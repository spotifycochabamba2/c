//
//  UIColorExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UIColor {
  
  static var cropswapGreen: UIColor {
    return hexStringToUIColor(hex: "#cee380")
  }
  static var cropswapRed: UIColor {
    return hexStringToUIColor(hex: "#f83f39")
  }
  
  static var cropswapYellow: UIColor {
    return hexStringToUIColor(hex: "#ecaa20")
  }
  static var cropswapBrown: UIColor {
    return hexStringToUIColor(hex: "#524c0d")
  }
  
  static func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
      return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}
