//
//  FeedCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell {

  @IBOutlet weak var shadowView: UIView!
  var shadowLayer = CALayer()
  
  var numberFormatter = { () -> NumberFormatter in
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = "USD"
    
    return formatter
  }()
  
  @IBOutlet weak var produceImageView: UIImageView! {
    didSet {
      produceImageView.contentMode = .scaleAspectFill
      produceImageView.layer.borderColor = UIColor.clear.cgColor
      produceImageView.layer.masksToBounds = true
      produceImageView.layer.borderWidth = 1.0
      produceImageView.layer.cornerRadius = 3
    }
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    shadowLayer.backgroundColor = UIColor.white.cgColor
    shadowLayer.shadowColor = UIColor.black.cgColor
    shadowLayer.shadowRadius = 12
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowOffset = CGSize(width: 0, height: -60)
    
    shadowView.layer.addSublayer(shadowLayer)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()    
    shadowView.layoutIfNeeded()
    
    shadowLayer.frame = CGRect(x: 0, y: shadowView.frame.size.height, width: shadowView.frame.size.width, height: 70)
  }
  
  @IBOutlet weak var produceNameLabel: UILabel! {
    didSet {
      produceNameLabel.text = ""
    }
  }
  
  @IBOutlet weak var priceLabel: UILabel! {
    didSet {
      priceLabel.text = ""
    }
  }
  
  @IBOutlet weak var distanceLabel: UILabel! {
    didSet {
      distanceLabel.text = "0 miles   away"
    }
  }
  
  var produceName = "" {
    didSet {
      produceNameLabel.text = produceName
    }
  }
  
  var price: Double = 0 {
    didSet {      
      if price == 0 {
        priceLabel.text = "FREE"
      } else {
        priceLabel.text = numberFormatter.string(from: NSNumber(value: price))
      }
    }
  }
  
  var distance: Double = 0.0 {
    didSet {
      let distanceString = String(format: "%.0f", distance)
      distanceLabel.text = "\(distanceString) miles away"
    }
  }
  
  var producePictureURL = "" {
    didSet {
      if let url = URL(string: producePictureURL) {
        produceImageView.sd_setImage(with: url)
      }
    }
  }
  
  
}

































