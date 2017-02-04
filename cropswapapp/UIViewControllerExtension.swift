//
//  UIViewControllerExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/1/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UIViewController: UITextFieldDelegate {
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
