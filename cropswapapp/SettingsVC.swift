//
//  SettingsVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
  @IBOutlet weak var logoutTableViewCell: UITableViewCell!
  @IBOutlet weak var privacyPolicyTableViewCell: UITableViewCell!
  @IBOutlet weak var termsConditionsTableViewCell: UITableViewCell!
}

extension SettingsVC {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.SettingsToTerms {
      let vc = segue.destination as? TermsConditionsVC
      vc?.comesFromSettings = true
    } else if segue.identifier == Storyboard.SettingsToPrivacy {
      let vc = segue.destination as? PrivacyPolicyVC
      vc?.comesFromSettings = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

//    navigationController?.navigationBar.isTranslucent = false
//    navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#f9f9f9")
    
    setNavHeaderTitle(title: "Settings", color: UIColor.black)
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .right)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
  }
  
  func backButtonTouched() {
    dismiss(animated: true)
  }
  
}

extension SettingsVC {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    switch cell {
    case logoutTableViewCell:
      print("logoutTableViewCell touched")
      dismiss(animated: true, completion: {
        NotificationCenter.default.post(
          name: Notification.Name(Constants.Ids.logoutId),
          object: nil
        )
      })
    case privacyPolicyTableViewCell:
      performSegue(withIdentifier: Storyboard.SettingsToPrivacy, sender: nil)
    case termsConditionsTableViewCell:
      performSegue(withIdentifier: Storyboard.SettingsToTerms, sender: nil)
    default:
      break
    }
  }
}






















