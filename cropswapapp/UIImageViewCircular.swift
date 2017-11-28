//
//  UIImageViewCircular.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class UIImageViewCircular: UIImageView {
  override var bounds: CGRect {
    didSet {
      self.layer.cornerRadius = frame.size.width / 2
      self.layer.borderWidth = 1
      self.layer.borderColor = UIColor.clear.cgColor
      self.layer.masksToBounds = true
      
      self.contentMode = .scaleAspectFit
    }
  }
}

