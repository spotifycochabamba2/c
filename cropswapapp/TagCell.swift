//
//  TagCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/23/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
  @IBOutlet weak var tagNameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()    

  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
    layer.borderColor = UIColor.black.cgColor
    layer.masksToBounds = true
    layer.borderWidth = 1.0
    layer.cornerRadius = 3
  }
}
