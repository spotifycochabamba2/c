//
//  YourLocationVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class YourLocationVC: UIViewController {
  var user: User?
  
  var upperViewOriginalFrame: CGRect!
  var viewOriginalFrame: CGRect!
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  @IBOutlet weak var showAddressSwitch: UISwitch!
  
  @IBOutlet weak var streetTextField: UITextField!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var stateTextField: UITextField!
  @IBOutlet weak var zipCodeTextField: UITextField!
  
  var didPerformSegueToHome: () -> Void = {}
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    upperViewOriginalFrame = upperView.frame
    viewOriginalFrame = view.frame
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil) //UIKeyboardWillHide
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(notification:)), name:NSNotification.Name.UIKeyboardDidChangeFrame, object: nil) //UIKeyboardWillChangeFrame
    
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
  }
  
  func keyboardWillBeHidden(notification: Notification) {
    if
      let viewOriginalFrame = viewOriginalFrame,
      let upperViewOriginalFrame = upperViewOriginalFrame
    {
      view.frame = viewOriginalFrame
      upperView.frame = upperViewOriginalFrame
    }
  }
  
  func keyboardWillBeShown(notification: Notification) {
    if let viewOriginalFrame = viewOriginalFrame {
      let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let keyboardHeight = keyboardRect!.origin.y
      let newPositionY = keyboardHeight - viewOriginalFrame.origin.y
      
      var frame = viewOriginalFrame
      
      frame.origin.y = (newPositionY - viewOriginalFrame.height) - (upperView.frame.height - view.frame.height) / 2
      
      view.frame = frame
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    streetTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    cityTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    stateTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    zipCodeTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
  }
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true) { [weak self] in
      self?.didPerformSegueToHome()
    }
  }
  
  @IBAction func okButtonTouched() {
    let street = streetTextField.text
    let city = cityTextField.text
    let state = stateTextField.text
    let zipCode = zipCodeTextField.text ?? ""
    let showAddress = showAddressSwitch.isOn
    
    guard let userId = user?.id else {
      let alert = UIAlertController(
        title: "Error",
        message: "User Id not provided to User.saveLocation",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      present(alert, animated: true)
      return
    }
    
    User.saveLocation(
      byUserId: userId,
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      showAddress: showAddress
    ) { [weak self] (error) in
      if let error = error {
        let alert = UIAlertController(
          title: "Error",
          message: error.localizedDescription,
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self?.present(alert, animated: true)
      } else {
        self?.dismiss(animated: true) { [weak self] in
          self?.didPerformSegueToHome()
        }
      }
    }
  }
}































