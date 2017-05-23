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
  
  var currentUserId: String?
  var currentUsername: String?
  
  @IBOutlet weak var streetCell: UITableViewCell!
  @IBOutlet weak var cityCell: UITableViewCell!
  @IBOutlet weak var stateCell: UITableViewCell!
  @IBOutlet weak var zipCodeCell: UITableViewCell!
  @IBOutlet weak var showAddressCell: UITableViewCell!
  
  var showBackButton = false
  
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
  
  
//  @IBOutlet weak var locationLabel: UILabel! {
//    didSet {
//      locationLabel.text = ""
//    }
//  }
  
  @IBOutlet weak var streetLabel: UILabel! {
    didSet {
      streetLabel.text = ""
    }
  }
  
  @IBOutlet weak var cityLabel: UILabel! {
    didSet {
      cityLabel.text = ""
    }
  }
  
  @IBOutlet weak var stateLabel: UILabel! {
    didSet {
      stateLabel.text = ""
    }
  }
  
  @IBOutlet weak var zipCodeLabel: UILabel! {
    didSet {
      zipCodeLabel.text = ""
    }
  }
  
  @IBOutlet weak var showAddressSwitch: UISwitch!
  
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
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = super.tableView(tableView, heightForRowAt: indexPath)
    
    if showBackButton {
      let cell = super.tableView(tableView, cellForRowAt: indexPath)
      
      if cell === streetCell {
        return 0
      } else if cell === cityCell {
        return 0
      } else if cell === stateCell {
        return 0
      } else if cell === zipCodeCell {
        return 0
      } else if cell === showAddressCell {
        return 0
      }
    }
    
    return height
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
    
    if showBackButton {
      setNavHeaderTitle(title: "\(currentUsername ?? "Someone")'s Profile", color: UIColor.black)
      
      let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
      leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    }
  }
  
  func backButtonTouched() {
    dismiss(animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }
    
    User.getUser(byUserId: currentUserId) { [weak self] (result) in
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
//    locationLabel.text = "\(user.location ?? "")"
    emailLabel.text = user.email
    
    profileImageURL = user.profilePictureURL
    
    streetLabel.text = user.street
    cityLabel.text = user.city
    stateLabel.text = user.state
    zipCodeLabel.text = user.zipCode
    
    showAddressSwitch.isOn = user.showAddress ?? false
  }
}












































