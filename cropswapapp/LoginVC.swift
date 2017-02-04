//
//  LoginVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class LoginVC: UITableViewController {
  
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var loginInstagramButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  var showSignupView: (() -> Void)?
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = true
    navigationController?.isNavigationBarHidden = true
    
    setupTableView()
    setupTextFields()
  }
  
  @IBAction func instagramButtonTouched() {
  }
  
  @IBAction func loginButtonTouched() {
  }
  
  @IBAction func forgotButtonTouched() {
  }
  
  @IBAction func signupButtonTouched() {
    showSignupView?()
  }
  
  func setupTableView() {
    tableView.backgroundColor = .clear
    tableView.backgroundView = UIImageView(image: UIImage(named: "intro-background-login"))
  }
  
  func setupTextFields() {

    emailTextField.backgroundColor = .clear
    passwordTextField.backgroundColor = .clear
    
    emailTextField.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 2)
    emailTextField.setPlaceholderColor(color: .white)
    
    passwordTextField.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 2)
    passwordTextField.setPlaceholderColor(color: .white)
    
    loginInstagramButton.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 5)
    
    signupButton.makeMeBordered(color: .cropswapBrown, borderWidth: 2, cornerRadius: 5)
    loginButton.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 5)
  }
}
