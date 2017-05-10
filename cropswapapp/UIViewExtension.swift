//
//  UIViewExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UIView {
  
  func applyShadowedBordered() {
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 0)
    self.layer.shadowRadius = 5
    self.layer.shadowOpacity = 0.1
  }
  
  func makeMeBordered(color: UIColor = UIColor.clear, borderWidth: CGFloat, cornerRadius: CGFloat) {
    self.layer.borderColor = color.cgColor
    self.layer.borderWidth = borderWidth
    self.layer.cornerRadius = cornerRadius

  }
  
  func makeMeBordered(color: UIColor = UIColor.clear) {
  
    self.layer.borderColor = color.cgColor
    self.layer.borderWidth = 1.5
    self.layer.cornerRadius = 8.0

  }
  
}
