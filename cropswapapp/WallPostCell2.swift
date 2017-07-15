//
//  WallPostCell2.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/10/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class WallPostCell2: UITableViewCell {
  static let identifier = "WallPostCell2Id"
  
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var profileImageView: UIImageViewCircular!
  

  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
//    leftView.layer.masksToBounds = false
////    leftView.layer.shadowColor = UIColor.lightGray.cgColor
//    leftView.layer.shadowColor = UIColor.red.cgColor
//    leftView.layer.shadowOffset = CGSize(width: 0, height: 5)
//    leftView.layer.shadowRadius = 1
//    leftView.layer.shadowOpacity = 0.5
  }
  
  var comment: Comment? {
    didSet {
      if let comment = comment {
        messageLabel.text = comment.text
        
        usernameLabel.text = comment.ownerUsername
        dateLabel.text = Utils.relativePast(for: comment.date)
//        dateLabel.text = Utils.dateFormatter.string(from: comment.date)
        
        if let url = URL(string: comment.ownerProfilePictureURL ?? "") {
          profileImageView.sd_setImage(with: url)
        }
      }
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    messageLabel.text = ""
  }
}
