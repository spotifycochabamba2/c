//
//  ProfileChildVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileChildVC: UITableViewController {
  
  @IBOutlet weak var nameLabel: UILabel! {
    didSet {
      nameLabel.text = ""
    }
  }
  
  @IBOutlet weak var phoneNumberLabel: UILabel! {
    didSet {
      phoneNumberLabel.text = ""
    }
  }
  
  @IBOutlet weak var emailLabel: UILabel! {
    didSet {
      emailLabel.text = ""
    }
  }
  
  @IBOutlet weak var websiteLabel: UILabel! {
    didSet {
      websiteLabel.text = ""
    }
  }
  
  
  @IBOutlet weak var locationLabel: UILabel! {
    didSet {
      locationLabel.text = ""
    }
  }
  
  @IBOutlet weak var profileImageView: UIImageView!{
    didSet {
      profileImageView.contentMode = .center
      profileImageView.backgroundColor = UIColor.hexStringToUIColor(hex: "#e1e3e5")
      profileImageView.image = UIImage(named: "cropswap-gray-logo")
    }
  }
  
  var profileImageURL: String? {
    didSet {
      
      if let url = URL(string: profileImageURL ?? "") {
        profileImageView.contentMode = .scaleAspectFit
        
        profileImageView.sd_setImage(with: url)
      }
      
    }
  }
  
    
  
  
//  @IBAction func takePictureButtonTouched() {
//    performSegue(withIdentifier: Storyboard.ProfileChildToCamera, sender: nil)
//  }
//  
//  @IBAction func pickPictureButtonTouched() {
//    
//  }
//  
//  @IBAction func deletePictureButtonTouched() {
//    
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }
    
    User.getUser { [weak self] (result) in
      SVProgressHUD.dismiss()
      switch result {
      case .success(let user):
        self?.loadUserInfoToUI(user: user)
      case .fail(let error):
        print(error)
        break
      }
    }
  }
  
  func loadUserInfoToUI(user: User) {
    nameLabel.text = "\(user.name) \(user.lastName ?? "")"
    phoneNumberLabel.text = "\(user.phoneNumber ?? "")"
    websiteLabel.text = "\(user.website ?? "")"
    locationLabel.text = "\(user.location ?? "")"
    emailLabel.text = user.email
    
    profileImageURL = user.profilePictureURL
  }
}












































