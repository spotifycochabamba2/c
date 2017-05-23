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
  
//  var logoutButton: UIButton!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.ProfileContainerToProfileChild {
      let vc = segue.destination as? ProfileChildVC
      vc?.currentUserId = User.currentUser?.uid
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  func showSettingsView() {
    performSegue(withIdentifier: Storyboard.ProfileChildToSettings, sender: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    
    setNavHeaderTitle(title: "My Profile", color: UIColor.black)
    
    let settingsButton = setNavIcon(imageName: "settings-icon", size: CGSize(width: 26, height: 26), position: .right)
    settingsButton.addTarget(self, action: #selector(showSettingsView), for: .touchUpInside)
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
  }
  
  @IBAction func editProfileButtonTouched() {
    performSegue(withIdentifier: Storyboard.ProfileContainerToEditProfileContainer, sender: nil)
  }
  
}























