//
//  UITextFieldExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
//
//extension UITextView {
//  func addBottomLine(color: UIColor) {
//    
//    let line = CALayer()
//    let borderWidth = CGFloat(1.0)
//    line.borderColor = color.cgColor
//    line.frame = CGRect(
//      x: 0,
//      y: self.frame.size.height - borderWidth,
//      width: self.frame.size.width,
//      height: self.frame.size.height)
//    line.borderWidth = borderWidth
//    
//    self.layer.addSublayer(line)
//    self.layer.masksToBounds = true
//  }
//}

extension UIView {
  func setPlaceholderColor(color: UIColor) {
    self.setValue(color, forKeyPath: "_placeholderLabel.textColor")
  }
  
  func addBottomLine(color: UIColor) {
    
    let line = CALayer()
    let borderWidth = CGFloat(1.0)
    line.borderColor = color.cgColor
    line.frame = CGRect(
      x: 0,
      y: self.frame.size.height - borderWidth,
      width: self.frame.size.width,
      height: self.frame.size.height)
    line.borderWidth = borderWidth
    
    self.layer.addSublayer(line)
    self.layer.masksToBounds = true
  }
}
