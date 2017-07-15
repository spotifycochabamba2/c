//
//  ProfileInstagramCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/4/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ProfileInstagramCell: UICollectionViewCell {
  
  static var identifierId = "ProfileInstagramCellId"
  @IBOutlet weak var instagramImageView: UIImageViewCircular!
  
  var instagramURLString = "" {
    didSet {
      if let url = URL(string: instagramURLString) {
        instagramImageView.sd_setImage(with: url)
      }
    }
  }
  
}
