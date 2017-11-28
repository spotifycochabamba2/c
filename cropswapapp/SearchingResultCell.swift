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
  
  var user: [String: Any]? {
    didSet {
      let pictureURL = user?["profilePictureURL"] as? String ?? ""
      let name = user?["name"] as? String ?? ""
      let lastName = user?["lastName"] as? String ?? ""
      let about = user?["about"] as? String ?? ""
      
      if let url = URL(string: pictureURL) {
        userImageView.sd_setImage(with: url)
      }
      
      nameLabel.text = "\(name) \(lastName)"

      statusLabel.text = about
    }
  }
  
 
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.image = nil
    nameLabel.text = ""
//    statusLabel.text = ""
  }
}
