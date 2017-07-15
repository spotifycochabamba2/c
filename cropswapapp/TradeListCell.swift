//
//  TradeListCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/14/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class TradeListCell: UITableViewCell {
  
  static let cellId = "tradeListCellId"
  @IBOutlet weak var userImageView: UIImageView! {
    didSet {
      let tapGesture = UITapGestureRecognizer(target: self, action:
        #selector(userImageViewTapped))
      tapGesture.numberOfTapsRequired = 1
      tapGesture.numberOfTouchesRequired = 1
      userImageView.isUserInteractionEnabled = true
      userImageView.addGestureRecognizer(tapGesture)
    }
  }
  
  var userImageTapped: (String, String) -> Void = { _ in }
  
  var anotherUserId: String = ""
  
  let userNameSemiboldFont = UIFont(name: "Montserrat-Semibold", size: 20)
  let numberProduceSemiboldFont = UIFont(name: "Montserrat-Semibold", size: 13)
  
  let userNameRegularFont = UIFont(name: "Montserrat-Regular", size: 20)
  let numberProduceLightFont = UIFont(name: "Montserrat-Light", size: 13)
  
  func userImageViewTapped() {
    userImageTapped(anotherUserId, username ?? "")
    print("user id touched was: \(anotherUserId)")
  }
  
  var hasNewNotifications = false {
    didSet {
      if hasNewNotifications {
        usernameLabel.font = userNameSemiboldFont
        numberProducesLabel.font = numberProduceSemiboldFont
      } else {
        usernameLabel.font = userNameRegularFont
        numberProducesLabel.font = numberProduceLightFont
      }
    }
  }
  
  var profilePictureURL: String? {
    didSet {
      if let url = URL(string: profilePictureURL ?? "") {
        userImageView.sd_setImage(with: url)
      } else {
        userImageView.image = nil 
      }
    }
  }
  
  @IBOutlet weak var usernameLabel: UILabel! {
    didSet {
      usernameLabel.text = ""
    }
  }
  
  @IBOutlet weak var numberProducesLabel: UILabel! {
    didSet {
      numberProducesLabel.text = ""
    }
  }
  
  @IBOutlet weak var stateLabel: UILabel! {
    didSet {
      stateLabel.text = ""
    }
  }
  
  @IBOutlet weak var dateLabel: UILabel! {
    didSet {
      dateLabel.text = ""
    }
  }
  
  var date: Double? {
    didSet {
      if let date = date {
        let dateDouble = date * -1
        
        // put in utils struct
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        let dealDate = Date(timeIntervalSince1970: dateDouble)
        dateLabel.text = "\(formatter.string(from: dealDate))"
      }
    }
  }
  
  var username: String? {
    didSet {
      usernameLabel.text = "\(username ?? "")"
    }
  }
  
  var numberProduces: Int? {
    didSet {
      numberProducesLabel.text = "\(numberProduces ?? 0) items to trade"
    }
  }
  
  var state: DealState? {
    didSet {
      
      if let state = state {
        switch state {
        case .tradeCompleted:
          stateLabel.textColor = .white
          stateLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "#37d67c")
          stateLabel.layer.borderColor = UIColor.clear.cgColor
          stateLabel.layer.borderWidth = 1
          stateLabel.layer.cornerRadius = 5
          stateLabel.layer.masksToBounds = true
        case .tradeInProcess:
          break
        case .tradeDeleted:
          break
        case .tradeCancelled:
          stateLabel.textColor = .white
          stateLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "#f83f39")
          stateLabel.layer.borderColor = UIColor.clear.cgColor
          stateLabel.layer.borderWidth = 1
          stateLabel.layer.cornerRadius = 5
          stateLabel.layer.masksToBounds = true
          break
        case .tradeRequest:
          stateLabel.textColor = .black
          stateLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "#d5d8dd")
          stateLabel.layer.borderColor = UIColor.clear.cgColor
          stateLabel.layer.borderWidth = 1
          stateLabel.layer.cornerRadius = 5
          stateLabel.layer.masksToBounds = true
          break
        case .waitingAnswer:
          stateLabel.textColor = .black
          stateLabel.backgroundColor = UIColor.white
          stateLabel.layer.borderColor = UIColor.hexStringToUIColor(hex: "#d5d8dd").cgColor
          stateLabel.layer.borderWidth = 1
          stateLabel.layer.cornerRadius = 5
          break
        }

        stateLabel.text = "   \(state.rawValue)  ."
      }
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    userImageView.layer.cornerRadius = 35
    userImageView.layer.masksToBounds = true
    userImageView.layer.borderWidth = 1
    userImageView.layer.borderColor = UIColor.clear.cgColor
  }
}
