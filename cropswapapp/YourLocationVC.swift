//
//  YourLocationVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class YourLocationVC: UIViewController {
  
  var currentActiveTextField: UITextField!
  var user: User?
  
  var upperViewOriginalFrame: CGRect!
  var viewOriginalFrame: CGRect!
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  @IBOutlet weak var showAddressSwitch: UISwitch!
  
  var countrySelected: String?
  var countriesTableViewDelegate: CountryDelegate!
  let countryTableViewHeight: CGFloat = 150.0
  
  @IBOutlet weak var countryTableView: UITableView!
  @IBOutlet weak var countryTableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var countryTextField: UITextField!
  @IBOutlet weak var streetTextField: UITextField!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var stateTextField: UITextField!
  @IBOutlet weak var zipCodeTitleLabel: UILabel!
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
  
  func didCountrySelect(_ country: String) {
    countryTextField.text = country
    countrySelected = country
    
    if country == Constants.Map.unitedStatesName {
      zipCodeTextField.text = ""
      zipCodeTextField.isEnabled = true
      zipCodeTextField.alpha = 1
      zipCodeTitleLabel.alpha = 1
    } else {
      zipCodeTextField.text = ""
      zipCodeTextField.isEnabled = false
      zipCodeTextField.alpha = 0.5
      zipCodeTitleLabel.alpha = 0.5
    }
    
    view.endEditing(true)
  }
  
  func viewTapped() {
    view.endEditing(true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    view.isMultipleTouchEnabled
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    tapGesture.delegate = self
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    view.addGestureRecognizer(tapGesture)
    
    countriesTableViewDelegate = CountryDelegate(tableView: countryTableView)
    countriesTableViewDelegate.setup()
    countriesTableViewDelegate.didCountrySelect = didCountrySelect
    
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
      UIView.animate(withDuration: 0.2, animations: { [weak self] in
        self?.view.frame = viewOriginalFrame
        self?.upperView.frame = upperViewOriginalFrame
      })
    }
  }
  
  func keyboardWillBeShown(notification: Notification) {
    if currentActiveTextField !== countryTextField {
      if let viewOriginalFrame = viewOriginalFrame {
        let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardRect!.origin.y
        let newPositionY = keyboardHeight - viewOriginalFrame.origin.y
        
        var frame = viewOriginalFrame
        
        frame.origin.y = (newPositionY - viewOriginalFrame.height) - (upperView.frame.height - view.frame.height) / 2
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
          self?.view.frame = frame
        })
      }
    } else {
      if let viewOriginalFrame = viewOriginalFrame {
        var frame = viewOriginalFrame
        frame.origin.y = viewOriginalFrame.origin.y - 100
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
          self?.view.frame = frame
        })
      }
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    countryTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
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
    let country = countryTextField.text ?? ""
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
    
    SVProgressHUD.show()
    
    User.saveLocation(
      byUserId: userId,
      country: country,
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      showAddress: showAddress
    ) { [weak self] (error) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      
      if let error = error {
        let alert = UIAlertController(
          title: "Error",
          message: error.localizedDescription,
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
          self?.present(alert, animated: true)
        }
      } else {
        DispatchQueue.main.async {
          self?.dismiss(animated: true) { [weak self] in
            DispatchQueue.main.async {
              self?.didPerformSegueToHome()
            }
          }
        }
      }
    }
  }
}

extension YourLocationVC: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    currentActiveTextField = textField
    
    if textField === countryTextField {
      countryTableViewHeightConstraint.constant = countryTableViewHeight
      
      UIView.animate(withDuration: 0.5, animations: { [weak self] in
        self?.view.layoutIfNeeded()
      })
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField === countryTextField {
      countryTableViewHeightConstraint.constant = 0
      
      UIView.animate(withDuration: 0.5, animations: { [weak self] in
        self?.view.layoutIfNeeded()
      })
    }
    
    countryTextField.text = countrySelected
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField === countryTextField {
      let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
      
      countriesTableViewDelegate.filterCountries(byText: newString)
    }
    
    return true
  }
  
}

extension YourLocationVC: UIGestureRecognizerDelegate {
//  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
  
    if touch.view?.isDescendant(of: countryTableView) ?? false {
//      let point = gestureRecognizer.location(in: countryTableView.superview?.superview)
//      return !view.frame.contains(point)
      return false
    } else {
      return true
    }
  }
}






























