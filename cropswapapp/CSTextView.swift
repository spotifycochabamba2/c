//
//  CSTextView.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/15/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class CSTextView: UITextView {
  
  var bottomLineLayer: CALayer?
  let borderWidth = CGFloat(1.0)
  
  func addLineToBottom() {
    bottomLineLayer = CALayer()
    
    bottomLineLayer?.borderColor = UIColor.hexStringToUIColor(hex: "#cacdcf").cgColor
//    bottomLineLayer?.frame = CGRect(
//      x: 0,
//      y: self.frame.size.height - borderWidth,
//      width: self.frame.size.width,
//      height: borderWidth)
    bottomLineLayer?.borderWidth = borderWidth
    
    if let bottomLineLayer = bottomLineLayer {
      self.layer.addSublayer(bottomLineLayer)
    }
    
    self.layer.masksToBounds = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    bottomLineLayer?.removeFromSuperlayer()
    bottomLineLayer = nil
    
    addLineToBottom()
    
    var frame = CGRect(
            x: 0,
            y: self.frame.size.height - borderWidth,
            width: self.frame.size.width,
            height: borderWidth
    )
    
    if self.contentSize.height > bounds.size.height {
      frame.origin.y = self.contentSize.height - borderWidth - 1
    } else {
      frame.origin.y = self.bounds.size.height - borderWidth - 1
    }
    
    
    bottomLineLayer?.frame = frame
    //      setNeedsDisplay()
    //      bottomLineLayer?.setNeedsDisplay()
    
  }
  
}
