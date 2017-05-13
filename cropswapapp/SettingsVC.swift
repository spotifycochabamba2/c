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
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavHeaderTitle(title: "Settings", color: UIColor.black)
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .right)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
  }
  
  func backButtonTouched() {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
}

extension SettingsVC {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    switch cell {
    case logoutTableViewCell:
      print("logoutTableViewCell touched")
      NotificationCenter.default.post(
        name: Notification.Name(Constants.Ids.logoutId),
        object: nil
      )
    case privacyPolicyTableViewCell :
      print("privacyPolicyTableViewCell")
    case termsConditionsTableViewCell:
      print("termsConditionsTableViewCell")
    default:
      break
    }
  }
}
