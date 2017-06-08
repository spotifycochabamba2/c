//
//  SearchingResultCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/7/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class SearchingResultCell: UITableViewCell {
  static let identifier = "SearchingResultCell"
  
  @IBOutlet weak var userImageView: UIImageViewCircular!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  
 
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.image = nil
    nameLabel.text = ""
    statusLabel.text = ""
  }
}
