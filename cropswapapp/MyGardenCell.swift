//
//  MyGardenCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

enum MyGardenCellType {
  case addItem, produce
}

class MyGardenCell: UICollectionViewCell {
  
  var quantity = "" {
    didSet {
      quantityLabel.text = quantity
    }
  }
  
  var imageURL = "" {
    didSet {
      guard let url = URL(string: imageURL) else { return }
      
      produceImageView.sd_setImage(with: url)
    }
  }
  
  var produceName = "" {
    didSet {
      produceNameLabel.text = produceName
    }
  }
  
  @IBOutlet weak var produceImageView: UIImageView! {
    didSet {
      produceImageView.contentMode = .scaleAspectFill
      produceImageView.layer.borderColor = UIColor.white.cgColor
      produceImageView.layer.masksToBounds = true
      produceImageView.layer.borderWidth = 1.0
      produceImageView.layer.cornerRadius = 12
    }
  }
  
  @IBOutlet weak var plusImageView: UIImageView!
  @IBOutlet weak var addItemLabel: UILabel!
  @IBOutlet weak var plusStackView: UIStackView!
  @IBOutlet weak var produceNameLabel: UILabel!
  
  @IBOutlet weak var quantityLabel: UILabel!
  
  public var type: MyGardenCellType! {
    didSet {
      switch type! {
      case .addItem:
        produceImageView.image = nil
        plusStackView.isHidden = false
        quantityLabel.isHidden = true
        produceNameLabel.isHidden = true
      case .produce:
        plusStackView.isHidden = true
        quantityLabel.isHidden = false
        produceNameLabel.isHidden = false
      }
    }
  }
}
