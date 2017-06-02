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
  
  @IBOutlet weak var openChatButton: UIButton!
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
  var transactionMethod: String?
  
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
    } else if segue.identifier == Storyboard.ProfileContainerToFinalizeTrade {
      let vc = segue.destination as? FinalizeTradeVC
      vc?.didConfirmOffer = didConfirmOffer
    } else if segue.identifier == Storyboard.ProfileContainerToMakeDeal {
      let vc = segue.destination as? MakeDealVC
      
      vc?.transactionMethod = transactionMethod
      vc?.anotherOwnerId = currentUserId
      vc?.anotherUsername = currentUsername
    } else if segue.identifier == Storyboard.ProfileContainerToChat {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TradeChatVC
      
      vc?.anotherUserId = currentUserId
      vc?.anotherUsername = currentUsername
      vc?.dealId = sender as? String
      vc?.usedForInbox = true
    }
  }
  
  func didConfirmOffer(_ howFinalized: String) {
    transactionMethod = howFinalized
    performSegue(withIdentifier: Storyboard.ProfileContainerToMakeDeal, sender: nil)
  }
  
  @IBAction func openChatButtonTouched() {
    guard let fromUserId = User.currentUser?.uid else {
      return
    }
    
    guard let toUserId = currentUserId else {
      return
    }
    
    SVProgressHUD.show()
    
    Inbox.getOrCreateInboxId(
      fromUserId: fromUserId,
      toUserId: toUserId) { (inboxId) in
        DispatchQueue.main.async { [weak self] in
          SVProgressHUD.dismiss()
          
          self?.performSegue(withIdentifier: Storyboard.ProfileContainerToChat, sender: inboxId)
        }
    }
  }
  
  @IBAction func makeDealButtonTouched() {
    makeDealButton.isEnabled = false
    makeDealButton.alpha = 0.5
    print(currentUserId)
    print(currentUsername)
    
    guard let ownerId = currentUserId else {
      return
    }
    
    guard let ownerName = currentUsername else {
      return
    }
    
    guard let currenUserId = User.currentUser?.uid else {
      return
    }
    
    if ownerId != currenUserId {
      SVProgressHUD.show()
      
      Deal.canUserMakeADeal(fromUserId: currenUserId, toUserId: ownerId, completion: { [weak self] (hoursLeft) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
          self?.enableMakeDealButton()
        }
        print(hoursLeft)
        
        if hoursLeft > 0 {
          let alert = UIAlertController(title: "Error", message: "You already have a trade in progress with \(ownerName), Please wait \(hoursLeft) seconds before you submit a new request to \(ownerName) or wait for his response!", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          
          self?.present(alert, animated: true)
        } else {
          self?.performSegue(withIdentifier: Storyboard.ProfileContainerToFinalizeTrade, sender: nil)
        }
        })
    } else {
      let alert = UIAlertController(title: "Info", message: "Sorry you can't make a deal with yourself", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      enableMakeDealButton()
    }
  }
  
  func enableMakeDealButton() {
    makeDealButton.isEnabled = true
    makeDealButton.alpha = 1
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
//    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissModals"), object: nil)
    
  }
  
  @IBAction func editProfileButtonTouched() {
    performSegue(withIdentifier: Storyboard.ProfileContainerToEditProfileContainer, sender: nil)
  }
  
}























