//
//  SignupTwoVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/19/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

public class SignupTwoVC: UITableViewController {
  
  var email: String?
  var password: String?
  var comesFromInstagram = false
  
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var continueButton: UIButton!
  var didPerformSegueToHome: () -> Void = { }
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.SignupTwoToLocationNotice {
      let vc = segue.destination as? LocationNoticeVC
      
      vc?.modalPresentationCapturesStatusBarAppearance = true
    }
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    firstNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    usernameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    lastNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    continueButton.makeMeBordered()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(goToHome),
      name: NSNotification.Name(rawValue: Constants.Ids.SignupTwoToHome),
      object: nil
    )
    
    setNavHeaderTitle(title: "Sign Up", color: UIColor.black)

    var leftButtonIcon: UIButton?
    
    if email != nil && password != nil {
      leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
      leftButtonIcon?.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    } else {
      leftButtonIcon = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    }
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
  }
  
  func goToHome() {
    dismiss(animated: true) {
      DispatchQueue.main.async {
        _ = self.navigationController?.popViewController(animated: true)
        self.didPerformSegueToHome()
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name(rawValue: Constants.Ids.SignupTwoToHome),
      object: nil
    )
  }
  
  @IBAction func continueButtonTouched() {
    let firstName = firstNameTextField.text ?? ""
    let lastName = lastNameTextField.text ?? ""
    let username = usernameTextField.text ?? ""
    
    SVProgressHUD.show()
    User.signup(
      email: email,
      andPassword: password,
      andFirstName: firstName,
      andLastName: lastName,
      andUsername: username) { (error) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        if let error = error {
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          
          DispatchQueue.main.async {
            self.present(alert, animated: true)
          }
        } else {
          DispatchQueue.main.async {
            self.performSegue(withIdentifier: Storyboard.SignupTwoToLocationNotice, sender: nil)
          }
        }
    }
  }
  
  
  public func backButtonTouched() {
    _ = navigationController?.popViewController(animated: true)
  }
  
  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    var height = super.tableView(tableView, heightForRowAt: indexPath)
    
    if indexPath.row == 0 {
      height = view.frame.size.height - CGFloat(240 + UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.size.height ?? 0))
      
      if height <= 116 {
        return 0
      }
    }
    
    return height
  }
  
}

extension SignupTwoVC {
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    scroll(to: continueButton)
    return true
  }
  
}

