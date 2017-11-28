//
//  InboxCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/1/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell {
  
  @IBOutlet weak var userImageView: UIImageViewCircular!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  
  let usernameRegularFont = UIFont(name: "Montserrat-Regular", size: 20)
  let usernameSemiboldFont = UIFont(name: "Montserrat-Semibold", size: 20)
  
  let messageRegularFont = UIFont(name: "Montserrat-Regular", size: 13)
  let messageSemiboldFont = UIFont(name: "Montserrat-Semibold", size: 13)
  
  static let identifier = "InboxCellId"
  
  var inbox: [String: Any]? {
    didSet {
      if let inbox = inbox {
        userImageURLString = inbox["profilePictureURL"] as? String
        name = inbox["name"] as? String
        time = inbox["dateUpdated"] as? Double
        messageText = inbox["text"] as? String
        hasNewNotifications = inbox["notifications"] as? Bool ?? false
      }
    }
  }
  
  var hasNewNotifications = false {
    didSet {
      if hasNewNotifications {
        usernameLabel.font = usernameSemiboldFont
        messageLabel.font = messageSemiboldFont
      } else {
        usernameLabel.font = usernameRegularFont
        messageLabel.font = messageRegularFont
      }
    }
  }
  
  var userImageURLString: String? {
    didSet {
      if let url = URL(string: userImageURLString ?? "") {
        userImageView.sd_setImage(with: url)
      }
    }
  }
  
  var name: String? {
    didSet {
      usernameLabel.text = name
    }
  }
  
  var time: Double? {
    didSet {
      if let time = time {
        let date = Date(timeIntervalSince1970: time * -1)
        
        // put in utils struct
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        timeLabel.text = "\(formatter.string(from: date))"
      }
    }
  }
  
  var messageText: String? {
    didSet {
      messageLabel.text = messageText
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
//    userImageView.backgroundColor = .red
//    userImageView.layer.cornerRadius = userImageView.frame.height / 2
//    userImageView.layer.masksToBounds = true
//    userImageView.layer.borderWidth = 1
//    userImageView.layer.borderColor = UIColor.clear.cgColor
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    userImageView.image = nil
    usernameLabel.text = ""
    timeLabel.text = ""
    messageLabel.text = ""
  }
  
}



































