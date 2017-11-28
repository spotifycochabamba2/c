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
  
//  @IBOutlet weak var yourNameLabel: UILabel!
  
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var signupInstagramButton: UIButton!

  @IBOutlet weak var logoCell: UITableViewCell!
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
      
      vc?.loggedSuccessfully = loggedSuccessfully
    } else if segue.identifier == Storyboard.SignupToHome {
      let vc = segue.destination as? HomeVC
      
      vc?.currentUser = sender as? User
    } else if segue.identifier == Storyboard.SignupToSignup2 {
      let vc = segue.destination as? SignupTwoVC
      
      let data = sender as? [String: Any]
      
      vc?.didPerformSegueToHome = performSegueToHome
      vc?.email = data?["email"] as? String
      vc?.password = data?["password"] as? String
    }
  }
  
  @IBAction func instagramButtonTouched() {
    performSegue(withIdentifier: Storyboard.SignupToInstagram, sender: nil)
  }
  
  func loggedSuccessfully(isNewUser: Bool) {
    if isNewUser {
      performSegue(withIdentifier: Storyboard.SignupToSignup2, sender: nil)
    } else {
      performSegue(withIdentifier: Storyboard.SignupToHome, sender: nil)
    }
  }
  
  func performSegueToHome() {
    performSegue(withIdentifier: Storyboard.SignupToHome, sender: userCreated)
  }
  
  @IBAction func signupButtonTouched() {
    let email = emailTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    let repeatPassword = repeatPasswordTextField.text ?? ""
    
    if case Result.fail(let error) = User.isValid(email: email) {
      let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    if case Result.fail(let error) = User.isValid(password: password) {
      let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    if password != repeatPassword {
      let alert = UIAlertController(title: "Error", message: "Password and Repeat Password should contain the same value.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    var dataToSend = [String: Any]()
    dataToSend["email"] = email
    dataToSend["password"] = password
    
    performSegue(withIdentifier: Storyboard.SignupToSignup2, sender: dataToSend)
  }
  
  func performSegueToHome(user: User) {
    performSegue(withIdentifier: Storyboard.SignupToHome, sender: user)
  }
  
  func setupTextFields() {
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
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    var height = super.tableView(tableView, heightForRowAt: indexPath)
    
    if indexPath.row == 0 {
      
//      let height = view.frame.size.height - 
      
      //420
      height = view.frame.size.height - CGFloat(360 + UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.size.height ?? 0))
      
      
      if height <= 80 {
        height = 0
      }
    }
    
    return height
  }

}






























