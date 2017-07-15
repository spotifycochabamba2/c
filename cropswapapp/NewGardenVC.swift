//
//  NewGardenVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class NewGardenVC: UIViewController {
  
  @IBOutlet weak var segmentedControlView: UIView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  @IBOutlet weak var gardenContainerView: UIView!
  @IBOutlet weak var updatesContainerView: UIView!
  @IBOutlet weak var profileContainerView: UIView!
  
  func showSettingsView() {
    performSegue(withIdentifier: Storyboard.NewGardenToSettings, sender: nil)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    let settingsButton = setNavIcon(imageName: "settings-icon", size: CGSize(width: 26, height: 26), position: .right)
    settingsButton.addTarget(self, action: #selector(showSettingsView), for: .touchUpInside)
    
    configureSegmentedControl(segmentedControl)
    
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.sendActions(for: .valueChanged)
  }
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.NewGardenToProfileContainer {
      let vc = segue.destination as? ProfileChildVC
      vc?.currentUserId = User.currentUser?.uid
    } else if segue.identifier == Storyboard.NewGardenToWall {
      
      let vc = segue.destination as? WallContainerVC
      vc?.wallOwnerId = User.currentUser?.uid
    }
  }
  
  @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
    
    if sender.selectedSegmentIndex == 0 {
      gardenContainerView.isHidden = false
      updatesContainerView.isHidden = true
      profileContainerView.isHidden = true
    } else if sender.selectedSegmentIndex == 1 {
      gardenContainerView.isHidden = true
      updatesContainerView.isHidden = false
      profileContainerView.isHidden = true
    } else {
      gardenContainerView.isHidden = true
      updatesContainerView.isHidden = true
      profileContainerView.isHidden = true
      gardenContainerView.isHidden = true
      profileContainerView.isHidden = false
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
}

