//
//  SignupVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignupVC: UITableViewController {
  
  @IBOutlet weak var yourNameLabel: UILabel!
  
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var signupInstagramButton: UIButton!

  @IBOutlet weak var logoCell: UITableViewCell!
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var repeatPasswordTextField: UITextField!
  
  var userCreated: User?
  
  var showLoginView: (() -> Void)?
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavHeaderTitle(title: "Sign Up", color: UIColor.black)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)

    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
    
//    setupTableView()

  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    setupTextFields()
  }
  
  func backButtonTouched() {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.SignupToInstagram {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? InstagramVC
      
      vc?.loggedSuccessfully = performSegueToHome
    } else if segue.identifier == Storyboard.SignupToHome {
      let vc = segue.destination as? HomeVC
      
      vc?.currentUser = sender as? User
    } else if segue.identifier == Storyboard.SignupToYourLocation {
      let vc = segue.destination as? YourLocationVC
      vc?.user = sender as? User
      vc?.didPerformSegueToHome = performSegueToHome
    }
  }
  
  @IBAction func instagramButtonTouched() {
    performSegue(withIdentifier: Storyboard.SignupToInstagram, sender: nil)
  }
  
  func performSegueToHome() {
    performSegue(withIdentifier: Storyboard.SignupToHome, sender: userCreated)
  }
  
  @IBAction func signupButtonTouched() {
    signupButton.isEnabled = false
    signupButton.alpha = 0.5
    
    let firstName = nameTextField.text ?? ""
    let lastName = lastNameTextField.text ?? ""
    let username = usernameTextField.text ?? ""
    let email = emailTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    let repeatPassword = repeatPasswordTextField.text ?? ""
        
    SVProgressHUD.show()
    User.signup(
      email: email,
      andFirstName: firstName,
      andLastName: lastName,
      andUsername: username,
      andPassword: password,
      andRepeatedPassword: repeatPassword) { [weak self] (result) in
        DispatchQueue.main.async {
          self?.signupButton.alpha = 1
          self?.signupButton.isEnabled = true
          SVProgressHUD.dismiss()
        }
        
        switch result {
        case .fail(let error):
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          DispatchQueue.main.async {
            self?.present(alert, animated: true)
          }
        case .success(let user):
          self?.userCreated = user
          
          DispatchQueue.main.async {
            self?.performSegue(withIdentifier: Storyboard.SignupToYourLocation, sender: user)
          }
        }
        
    }
  }
  
  func performSegueToHome(user: User) {
    performSegue(withIdentifier: Storyboard.SignupToHome, sender: user)
  }
  
  func setupTextFields() {
    nameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    lastNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    usernameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    emailTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    passwordTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    repeatPasswordTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    signupInstagramButton.makeMeBordered()
    signupInstagramButton.applyShadowedBordered()
    signupButton.makeMeBordered()
  }
  
  func setupTableView() {
    tableView.backgroundColor = .white
  }
  
}

extension SignupVC {
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    scroll(to: signupButton)
    return true
  }
  
}

extension SignupVC {
  
//  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    var height = super.tableView(tableView, heightForRowAt: indexPath)
//    
//    if indexPath.row == 0 {
//      height = view.frame.size.height - CGFloat(420 + UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.size.height ?? 0))
//      
//      if height < 0 {
//        height = 0
//      }
//    }
//    
//    return height
//  }

}






























