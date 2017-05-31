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
  @IBOutlet weak var profileContainerView: UIView!
  @IBOutlet weak var gardenContainerView: UIView!
  
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var makeDealView: UIView!
//  var logoutButton: UIButton!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var segmentedControlView: UIView!
  
  @IBOutlet weak var makeDealViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var segmentedControlViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var makeDealButton: UIButton! {
    didSet {
      makeDealButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  @IBOutlet weak var makeDealButtonBottomConstraint: NSLayoutConstraint!
  var currentUserId: String?
  var currentUsername: String?
  var showBackButton = false
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.ProfileContainerToProfileChild {
      let vc = segue.destination as? ProfileChildVC
//      vc?.currentUserId = User.currentUser?.uid
      vc?.currentUserId = currentUserId
      vc?.currentUsername = currentUsername
      print(showBackButton)
      vc?.showBackButton = showBackButton
    } else if segue.identifier == Storyboard.ProfileContainerToGarden {
      let vc = segue.destination as? GardenVC
      vc?.currentUserId = self.currentUserId
      vc?.isCurrentOwner = false
    }
  }
  
  @IBAction func makeDealButtonTouched() {
    
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    makeDealView.layer.shadowOffset = CGSize(width: 0, height: 0);
    makeDealView.layer.shadowRadius = 2;
    makeDealView.layer.shadowColor = UIColor.black.cgColor
    makeDealView.layer.shadowOpacity = 0.3;
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
  
  
  @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      profileContainerView.isHidden = false
      gardenContainerView.isHidden = true
    } else {
      profileContainerView.isHidden = true
      gardenContainerView.isHidden = false
    }
  }

  
  func configureSegmentedControl(_ control: UISegmentedControl) {
    
    let font = UIFont(name: "Montserrat-Regular", size: 11)
    let fontColorSelected = UIColor.white
    let fontColorNotSelected = UIColor.hexStringToUIColor(hex: "#F83F39")
    
    let selectedAttributes = [
      NSFontAttributeName: font!,
      NSForegroundColorAttributeName: fontColorSelected
    ]
    
    let notSelectedAttributes = [
      NSFontAttributeName: font!,
      NSForegroundColorAttributeName: fontColorNotSelected
    ]
    
    segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    segmentedControl.setTitleTextAttributes(notSelectedAttributes, for: .normal)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureSegmentedControl(segmentedControl)
    
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.sendActions(for: .valueChanged)
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    
    setNavHeaderTitle(title: "My Profile", color: UIColor.black)
    
    
    
    if showBackButton {
      editButton.isHidden = true
      
      setNavHeaderTitle(title: "\(currentUsername ?? "Someone")'s Profile", color: UIColor.black)
      
      let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
      leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    } else {
      makeDealViewHeightConstraint.constant = 0
      makeDealButton.isHidden = true
      
      segmentedControl.isHidden = true
      segmentedControlViewHeightConstraint.constant = 0.5
      
      let settingsButton = setNavIcon(imageName: "settings-icon", size: CGSize(width: 26, height: 26), position: .right)
      settingsButton.addTarget(self, action: #selector(showSettingsView), for: .touchUpInside)
    }
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
  }
  
  func backButtonTouched() {
    print("gaytan from profile container navigation controller vc count: \(navigationController?.viewControllers.count)")
    dismiss(animated: true)
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissModals"), object: nil)
    
  }
  
  @IBAction func editProfileButtonTouched() {
    performSegue(withIdentifier: Storyboard.ProfileContainerToEditProfileContainer, sender: nil)
  }
  
}























