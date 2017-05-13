//
//  ForgotPasswordVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class ForgotPasswordVC: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  var upperViewOriginalFrame: CGRect!
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true)
  }
  
  @IBAction func okButtonTouched() {
    let email = emailTextField.text ?? ""
    
    SVProgressHUD.show()
    User.sendResetPasswordTo(email: email) { [weak self] (error) in
      SVProgressHUD.dismiss()
      
      if let error = error {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self?.present(alert, animated: true)
      } else {
        self?.view.endEditing(true)
        
        let alert = UIAlertController(title: "Success", message: "A reset password link was sent to the email address provided.", preferredStyle: .alert)
       
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
          self?.dismiss(animated: true)
        }))
        
        self?.present(alert, animated: true)
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
}

extension ForgotPasswordVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    upperViewOriginalFrame = upperView.frame
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    emailTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
  }
  
  func keyboardWillBeHidden(notification: Notification) {
    upperView.frame = upperViewOriginalFrame
  }
  
  func keyboardWillBeShown(notification: Notification) {
    let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    let keyboardHeight = keyboardRect!.origin.y
    let newPositionY = keyboardHeight - view.frame.origin.y
    
    var frame = upperView.frame
    frame.origin.y = newPositionY - upperView.frame.height
    
    upperView.frame = frame
  }
}

extension ForgotPasswordVC {
  
}
























