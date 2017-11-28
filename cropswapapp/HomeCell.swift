//
//  HomeCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class HomeCell: UICollectionViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var pictureImageView: UIImageView! {
    didSet {
      pictureImageView.contentMode = .scaleAspectFill
      pictureImageView.layer.borderColor = UIColor.clear.cgColor
      pictureImageView.layer.masksToBounds = true
      pictureImageView.layer.borderWidth = 1.0
      pictureImageView.layer.cornerRadius = 12
    }
  }
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  
  var numberFormatter = { () -> NumberFormatter in
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = "USD"
    
    return formatter
  }()
  
  var produceName = "" {
    didSet {
      nameLabel.text = produceName
    }
  }
  
  var producePictureURL = "" {
    didSet {
      if let url = URL(string: producePictureURL) {
        pictureImageView.sd_setImage(with: url)
      }
    }
  }
  
  var price: Double = 0 {
    didSet {
      priceLabel.text = numberFormatter.string(from: NSNumber(value: price))
    }
  }
  
  var username = "" {
    didSet {
      usernameLabel.text = username
    }
  }
  
  var distance = 0 {
    didSet {
      distanceLabel.text = "\(distance) m"
    }
  }
  
  @IBAction func addButtonTouched() {
  }
}










































