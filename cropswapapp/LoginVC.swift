//
//  LoginVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginVC: UITableViewController {
  
  @IBOutlet weak var buttonsCell: UITableViewCell!
  
  @IBOutlet weak var logoCell: UITableViewCell!
  
  @IBOutlet weak var loginInstagramButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  var showSignupView: (() -> Void)?
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavHeaderTitle(title: "Login", color: UIColor.black)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    passwordTextField.delegate = self
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
    
    setupTableView()
  }
  
  func backButtonTouched() {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    setupTextFields()
  }
  
  func performSegueToHome(user: User) {
    performSegue(withIdentifier: Storyboard.LoginToHome, sender: user)
  }
  
  @IBAction func instagramButtonTouched() {
    performSegue(withIdentifier: Storyboard.LoginToInstagram, sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.LoginToHome {
      let vc = segue.destination as? HomeVC
      
      vc?.currentUser = sender as? User
    } else if segue.identifier == Storyboard.LoginToInstagram {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? InstagramVC
      
      vc?.performSegueToHome = performSegueToHome
    }
  }
  
  @IBAction func loginButtonTouched() {
    let email = emailTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    
    SVProgressHUD.show()
    User.login(email: email, password: password) { [weak self] (result) in
      SVProgressHUD.dismiss()
      
      switch result {
      case .success(let user):
        DispatchQueue.main.async {
          self?.performSegue(withIdentifier: Storyboard.LoginToHome, sender: user)
        }
        break
        
      case .fail(let error):
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
          self?.present(alert, animated: true)
        }
        break
      }
      
    }
  }
  
  func setupTableView() {
    tableView.backgroundColor = .white
  }
  
  
  
  func setupTextFields() {
    emailTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    passwordTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    loginButton.makeMeBordered()
    loginInstagramButton.makeMeBordered()
    loginInstagramButton.applyShadowedBordered()
  }
}

extension LoginVC: UITextFieldDelegate {
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    scroll(to: loginButton)
    return true
  }
  
}

extension LoginVC {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    var height = super.tableView(tableView, heightForRowAt: indexPath)
    
    if indexPath.row == 0 {
      height = view.frame.size.height - CGFloat(300 + UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.size.height ?? 0))
    }
    
    return height
  }
}
















