//
//  UITextFieldExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UITextField {
  func setPlaceholderColor(color: UIColor) {
    self.setValue(color, forKeyPath: "_placeholderLabel.textColor")
  }
}
