//
//  UIViewExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UIView {
  
  func makeMeBordered(color: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
    self.layer.borderColor = color.cgColor
    self.layer.borderWidth = borderWidth
    self.layer.cornerRadius = cornerRadius

  }
  
  func makeMeBordered(color: UIColor = UIColor.clear) {
  
    self.layer.borderColor = color.cgColor
    self.layer.borderWidth = 1.5
    self.layer.cornerRadius = 4.0

  }
  
}
