//
//  ProfileVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileContainerVC: UIViewController {
  
  var logoutButton: UIButton!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let _ = segue.destination as? EditProfileContainerVC
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  func logoutButtonTouched() {
    
    NotificationCenter.default.post(
      name: Notification.Name(Constants.Ids.logoutId),
      object: nil
    )
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    
    setNavHeaderTitle(title: "My Profile", color: UIColor.black)
    
    logoutButton = setNavIcon(imageName: "logout-icon", size: CGSize(width: 35, height: 25), position: .right)
    logoutButton.addTarget(self, action: #selector(logoutButtonTouched), for: .touchUpInside)
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
  }
  
  @IBAction func editProfileButtonTouched() {
    performSegue(withIdentifier: Storyboard.ProfileContainerToEditProfileContainer, sender: nil)
  }
  
}
