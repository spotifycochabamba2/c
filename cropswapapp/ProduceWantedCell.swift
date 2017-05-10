//
//  ProduceWantedCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/15/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ProduceWantedCell: UICollectionViewCell {
  @IBOutlet weak var circleView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  
  var name = "" {
    didSet {
      nameLabel.text = name
    }
  }
  
  var isProduceSelected = false {
    didSet {
      if isProduceSelected {
        circleView.layer.borderColor = UIColor.black.cgColor
      } else {
        circleView.layer.borderColor = UIColor.white.cgColor
      }
    }
  }
  
  func configure() {
    circleView.backgroundColor = .white
    circleView.layer.borderWidth = 2.0
  }
  
//  override func awakeFromNib() {
//    super.awakeFromNib()
//    
//    
//  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    print(circleView.frame.size.width)
    circleView.layer.cornerRadius = 90.5 / 2
  }
}
