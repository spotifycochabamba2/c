//
//  UIFontExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

  // Regular, Semibold, Light
  static func monserratFont(type: String, size: CGFloat) -> UIFont {
    return UIFont(name: "Montserrat-\(type)", size: 9)!
  }
  
}
