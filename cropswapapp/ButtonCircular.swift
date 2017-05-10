//
//  ButtonCircular.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/13/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ButtonCircular: UIButton {
  override var bounds: CGRect {
    didSet {
      print(frame.size.width)
      self.layer.cornerRadius = frame.size.width / 2
      self.layer.borderWidth = 1
      self.layer.borderColor = UIColor.clear.cgColor
      self.layer.masksToBounds = true
    }
  }
}
