//
//  DistanceControlVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/15/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

public class DistanceControlVC: UIViewController {
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var valueLabel: UILabel!
  @IBOutlet weak var valueMilesLabel: UILabel!
  @IBOutlet weak var enableFilterSwitch: UISwitch!
  var enableFilterRadiusFromFeedContainer = false
  
  var currentDistance = 0 {
    didSet {
      DispatchQueue.main.async { [weak self] in
        if let this = self {
          this.valueLabel.text = "\(this.currentDistance)"
          
        }
      }
    }
  }
  
  var enabledFilterRadius = false {
    didSet {
      if enabledFilterRadius {
        valueMilesLabel.alpha = 1
        valueLabel.alpha = 1
        slider.isEnabled = true
        slider.alpha = 1
      } else {
        valueMilesLabel.alpha = 0.5
        valueLabel.alpha = 0.5
        slider.isEnabled = false
        slider.alpha = 0.5
      }
    }
  }
  
  @IBAction func enabledFilterSwitchChanged() {
    enabledFilterRadius = !enabledFilterRadius
  }
  
  var didSelectDistance: (Int) -> Void = { _ in }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    currentDistance = Constants.Map.radius
    enabledFilterRadius = false
    enableFilterSwitch.isOn = false
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
    
    if enableFilterRadiusFromFeedContainer {
      enabledFilterRadius = true
      enableFilterSwitch.isOn = true
    }
    
    SVProgressHUD.show()
    User.getUser(byUserId: User.currentUser?.uid) { [weak self] (result) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      
      switch result {
      case .success(let user):
        self?.currentDistance = user.radiusFilterInMiles ?? Constants.Map.radius
        DispatchQueue.main.async {
//          self?.enabledFilterRadius = user.enabledRadiusFilter ?? true
          self?.slider.value = Float(user.radiusFilterInMiles ?? Constants.Map.radius)
//          self?.enableFilterSwitch.isOn = user.enabledRadiusFilter ?? true
        }
        break
      case .fail(let error):
        break
      }
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  @IBAction func slidedValueChanged(_ sender: AnyObject) {
    currentDistance = lroundf(slider.value)
  }
  
  override public func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
  }
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true)
  }
  
  @IBAction public func acceptButtonTouched() {
    if let userId = User.currentUser?.uid {
//      User.saveEnabledFilterRadius(
//        byUserId: userId,
//        enabledFilterRadius: enabledFilterRadius,
//        completion: { (error) in
//          if error != nil {
//
//          }
//        })
      
      if enabledFilterRadius {
        SVProgressHUD.show()
        
        didSelectDistance(currentDistance)
        User.saveRadius(
          byUserId: userId,
          radiusInMiles: currentDistance,
          completion: { [weak self] (error) in
            DispatchQueue.main.async {
              SVProgressHUD.dismiss()
            }
            
            self?.dismiss(animated: true)
            
          })
      } else {
        didSelectDistance(0)
        dismiss(animated: true)
      }
    } else {
      dismiss(animated: true)
    }
  }
}

















