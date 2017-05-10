//
//  FinalizeTradeVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/27/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class FinalizeTradeVC: UIViewController {
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  @IBOutlet weak var firstOptionView: UIView!
  @IBOutlet weak var secondOptionView: UIView!
  @IBOutlet weak var thirdOptionView: UIView!
  
  @IBOutlet weak var firstOptionImageView: UIImageView!
  @IBOutlet weak var secondOptionImageView: UIImageView!
  @IBOutlet weak var thirdOptionImageView: UIImageView!
  
  var didConfirmOffer: (String) -> Void = { _ in }
  
  var isFirstOptionSelected = false {
    didSet {
      if isFirstOptionSelected {
        firstOptionImageView.image = UIImage(named: "icon-tag-selected")
        firstOptionView.layer.borderColor = UIColor.red.cgColor
      } else {
        firstOptionImageView.image = UIImage(named: "icon-tag-not-selected")
        firstOptionView.layer.borderColor = UIColor.clear.cgColor
      }
    }
  }
  
  var isSecondOptionSelected = false {
    didSet {
      if isSecondOptionSelected {
        secondOptionImageView.image = UIImage(named: "icon-tag-selected")
        secondOptionView.layer.borderColor = UIColor.red.cgColor
      } else {
        secondOptionImageView.image = UIImage(named: "icon-tag-not-selected")
        secondOptionView.layer.borderColor = UIColor.clear.cgColor
      }
    }
  }
  
  var isThirdOptionSelected = false {
    didSet {
      if isThirdOptionSelected {
        thirdOptionImageView.image = UIImage(named: "icon-tag-selected")
        thirdOptionView.layer.borderColor = UIColor.red.cgColor
      } else {
        thirdOptionImageView.image = UIImage(named: "icon-tag-not-selected")
        thirdOptionView.layer.borderColor = UIColor.clear.cgColor
      }
    }
  }
  
  func firstOptionViewTapped() {
    isFirstOptionSelected = true
    isSecondOptionSelected = false
    isThirdOptionSelected = false
  }
  
  func secondOptionViewTapped() {
    isFirstOptionSelected = false
    isSecondOptionSelected = true
    isThirdOptionSelected = false
  }
  
  func thirdOptionViewTapped() {
    isFirstOptionSelected = false
    isSecondOptionSelected = false
    isThirdOptionSelected = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let firstOptionViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(firstOptionViewTapped))
    firstOptionViewTapGesture.numberOfTapsRequired = 1
    firstOptionViewTapGesture.numberOfTouchesRequired = 1
    firstOptionView.addGestureRecognizer(firstOptionViewTapGesture)
    
    let secondOptionViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(secondOptionViewTapped))
    secondOptionViewTapGesture.numberOfTouchesRequired = 1
    secondOptionViewTapGesture.numberOfTapsRequired = 1
    secondOptionView.addGestureRecognizer(secondOptionViewTapGesture)
    
    let thirdOptionViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(thirdOptionViewTapped))
    thirdOptionViewTapGesture.numberOfTapsRequired = 1
    thirdOptionViewTapGesture.numberOfTouchesRequired = 1
    thirdOptionView.addGestureRecognizer(thirdOptionViewTapGesture)
    
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
    
    firstOptionView.layer.borderWidth = 1
    firstOptionView.layer.cornerRadius = 5.0
    firstOptionView.layer.shadowColor = UIColor.black.cgColor
    firstOptionView.layer.shadowOffset = CGSize(width: 0, height: 0)
    firstOptionView.layer.shadowRadius = 7
    firstOptionView.layer.shadowOpacity = 0.2
    firstOptionView.layer.borderColor = UIColor.clear.cgColor
    
    secondOptionView.layer.borderWidth = 1
    secondOptionView.layer.cornerRadius = 5.0
    secondOptionView.layer.shadowColor = UIColor.black.cgColor
    secondOptionView.layer.shadowOffset = CGSize(width: 0, height: 0)
    secondOptionView.layer.shadowRadius = 7
    secondOptionView.layer.shadowOpacity = 0.2
    secondOptionView.layer.borderColor = UIColor.clear.cgColor
    
    thirdOptionView.layer.borderWidth = 1
    thirdOptionView.layer.cornerRadius = 5.0
    thirdOptionView.layer.shadowColor = UIColor.black.cgColor
    thirdOptionView.layer.shadowOffset = CGSize(width: 0, height: 0)
    thirdOptionView.layer.shadowRadius = 7
    thirdOptionView.layer.shadowOpacity = 0.2
    thirdOptionView.layer.borderColor = UIColor.clear.cgColor
  }
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true)
  }
  
  @IBAction func acceptButtonTouched() {    
    if !isFirstOptionSelected &&
        !isSecondOptionSelected &&
      !isThirdOptionSelected {
      let alert = UIAlertController(title: "Error", message: "Please select at least one option.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    var howFinalized = ""
    
    if isFirstOptionSelected {
      howFinalized = HowFinalized.illDrive.rawValue
    } else if isSecondOptionSelected {
      howFinalized = HowFinalized.youDriveIllTip.rawValue
    } else if isThirdOptionSelected {
      howFinalized = HowFinalized.letsMeetHalfway.rawValue
    }
    
    dismiss(animated: true) { [weak self] in
      self?.didConfirmOffer(howFinalized)
    }
  }
  
}



















