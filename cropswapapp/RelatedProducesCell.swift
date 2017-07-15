//
//  RelatedProducesCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/23/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class RelatedProduceCell: UICollectionViewCell {
  
  static var identifierId = "RelatedProducesCellId"
  
  @IBOutlet weak var imageView: UIImageView! {
    didSet {

    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    print("RelatedProduceCell awakeFromNib")
    
    self.contentView.isOpaque = false
    self.backgroundView?.isOpaque = false
    
    imageView.contentMode = .scaleAspectFill
    
    
//    UIImage* image = ...;
//    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
//    // Add a clip before drawing anything, in the shape of an rounded rect
//    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
//    cornerRadius:50.0] addClip];
//    // Draw your image
//    [image drawInRect:imageView.bounds];
//    
//    // Get the image, here setting the UIImageView image
//    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    // Lets forget about that we were drawing
//    UIGraphicsEndImageContext();
    
    
    
    
    
    
//    self.layer.masksToBounds = true
    
//    self.contentView.layer.borderColor = UIColor.clear.cgColor
//    self.contentView.layer.masksToBounds = true
//    self.contentView.layer.borderWidth = 1.0
//    self.contentView.layer.cornerRadius = 30
    
    

    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 30
//    imageView.layer.shouldRasterize = true
//    imageView.layer.rasterizationScale = UIScreen.main.scale
  }
  
  var imageURL: String? {
    didSet {
      if let imageURL = imageURL {
        if let url = URL(string: imageURL) {
          imageView.sd_setImage(with: url)
        } else {
          imageView.image = nil
        }
      } else {
        imageView.image = nil
      }
    }
  }
}
