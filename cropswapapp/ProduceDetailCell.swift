//
//  ProduceDetailCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/8/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ProduceDetailCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.contentMode = .scaleAspectFill
      imageView.backgroundColor = UIColor.cropswapRed
      imageView.layer.borderColor = UIColor.white.cgColor
      imageView.layer.masksToBounds = true
      imageView.layer.borderWidth = 1.0
      imageView.layer.cornerRadius = 12
    }
  }
  
  var pictureURL: String? {
    didSet {
      if let pictureURL = pictureURL {
        if let url = URL(string: pictureURL) {

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
