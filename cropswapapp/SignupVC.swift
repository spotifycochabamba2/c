//
//  SignupVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class SignupVC: UITableViewController {
  
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var signupInstagramButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  var showLoginView: (() -> Void)?
  
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
  
  @IBAction func signupButtonTouched() {
  }
  
  @IBAction func loginButtonTouched() {
    showLoginView?()
  }
  
  
  func setupTextFields() {
    nameTextField.backgroundColor = .clear
    emailTextField.backgroundColor = .clear
    passwordTextField.backgroundColor = .clear
    
    nameTextField.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 2)
    nameTextField.setPlaceholderColor(color: .white)
    
    emailTextField.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 2)
    emailTextField.setPlaceholderColor(color: .white)
    
    passwordTextField.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 2)
    passwordTextField.setPlaceholderColor(color: .white)
    
    signupInstagramButton.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 5)
    
    signupButton.makeMeBordered(color: .white, borderWidth: 2, cornerRadius: 5)
    loginButton.makeMeBordered(color: .cropswapBrown, borderWidth: 2, cornerRadius: 5)
  }
  
  func setupTableView() {
    tableView.backgroundColor = .clear
    tableView.backgroundView = UIImageView(image: UIImage(named: "intro-background-signup"))
  }
  
}
































