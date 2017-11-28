//
//  UILabelExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 10/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UILabel {
  func underline() {
    if let textString = self.text?.trimmingCharacters(in: CharacterSet.whitespaces),
       !textString.isEmpty
    {
      let attributedString = NSMutableAttributedString(string: textString)
      attributedString.addAttribute(
        NSUnderlineStyleAttributeName,
        value: NSUnderlineStyle.styleSingle.rawValue,
        range: NSRange(location: 0, length: attributedString.length)
      )
      attributedText = attributedString
    }
  }
}
