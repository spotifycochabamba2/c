//
//  UIImageExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/27/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UIImage {
  
  func resizeImage(withTargerSize size: CGSize) -> UIImage {
    let imageSize = self.size
    let widthRatio = size.width / imageSize.width
    let heightRatio = size.height / imageSize.height
    
    var newSize = CGSize.zero
    
    if widthRatio > heightRatio {
      newSize = CGSize(width: imageSize.width * heightRatio, height: imageSize.height * heightRatio)
    } else {
      newSize = CGSize(width: imageSize.width * widthRatio, height: imageSize.height * widthRatio)
    }
    
    let scaledRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0)
    self.draw(in: scaledRect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }
  
}
