//
//  MyGardenHeaderCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SDWebImage

class MyGardenHeaderCell: UICollectionReusableView {
  
  var openCameraVC: () -> Void = {}
  
  @IBOutlet weak var profileImageView: UIImageView! {
    didSet {
      profileImageView.contentMode = .scaleAspectFill
      profileImageView.image = UIImage(named: "camera-icon")
      profileImageView.isUserInteractionEnabled = true
      
      let tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
      tapGestureRecog.numberOfTapsRequired = 1
      tapGestureRecog.numberOfTouchesRequired = 1
      
      profileImageView.addGestureRecognizer(tapGestureRecog)
    }
  }

  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  var address: String? {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.addressLabel.text = self?.address
      }
    }
  }
  
  var username: String? {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.usernameLabel.text = self?.username
      }
    }
  }
  
  var userProfileImageURL: String? {
    didSet {
      if let stringURL = userProfileImageURL {
        guard let url = URL(string: stringURL) else { return }
        
        DispatchQueue.main.async { [weak self] in
          self?.profileImageView.sd_setImage(with: url)
          self?.profileImageView.layer.borderColor = UIColor.white.cgColor
          self?.profileImageView.layer.masksToBounds = true
          self?.profileImageView.layer.borderWidth = 1.0
          self?.profileImageView.layer.cornerRadius = 12
        }
      }
    }
  }
  
  func profileImageViewTapped() {
    openCameraVC()
  }
  
}
