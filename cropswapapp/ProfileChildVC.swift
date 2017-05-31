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
  var showBackButton = false
  
  
  @IBOutlet weak var aboutCell: UITableViewCell!
  @IBOutlet weak var streetCell: UITableViewCell!
  @IBOutlet weak var cityCell: UITableViewCell!
  @IBOutlet weak var stateCell: UITableViewCell!
  @IBOutlet weak var zipCodeCell: UITableViewCell!
  @IBOutlet weak var showAddressCell: UITableViewCell!    
  @IBOutlet weak var emailAddressCell: UITableViewCell!
  @IBOutlet weak var phoneNumberCell: UITableViewCell!
  
  @IBOutlet weak var aboutLabel: UILabel! {
    didSet {
      aboutLabel.text = ""
    }
  }
  
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
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if showBackButton {
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
      } else if cell == phoneNumberCell {
        return 0
      } else if cell == emailAddressCell {
        return 0
      }
    }
  
    if cell === aboutCell {

//      print("wtf cell \(cell.contentView.frame.height)")
//      print("wtf label \(aboutLabel.frame.height)")
//      print("wtf label.text \(aboutLabel.text)")
//      return cell.contentView.frame.height
      return UITableViewAutomaticDimension
    }
    
    return height
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension
    
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

    self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#f9f9f9")
    
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }
    
    User.getUser(byUserId: currentUserId) { [weak self] (result) in
      SVProgressHUD.dismiss()
      switch result {
      case .success(let user):
        DispatchQueue.main.async {
          self?.loadUserInfoToUI(user: user)
        }
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

    emailLabel.text = user.email
    
    profileImageURL = user.profilePictureURL
    
    streetLabel.text = user.street
    cityLabel.text = user.city
    stateLabel.text = user.state
    zipCodeLabel.text = user.zipCode
    
    showAddressSwitch.isOn = user.showAddress ?? false
    aboutLabel.text = user.about
    
    tableView.reloadData()
  }
}












































