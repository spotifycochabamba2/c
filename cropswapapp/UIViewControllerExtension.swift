//
//  UIViewControllerExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/1/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public enum NavIconPosition {
  case right, left
}

extension UIViewController {
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func onTouchUpInside() {
    
  }
  
  public var navigationBarIsHidden: Bool {
    set {
      navigationController?.navigationBar.isHidden = newValue
      navigationController?.isNavigationBarHidden = newValue
    }
    
    get {
      return navigationController?.navigationBar.isHidden ?? false && navigationController?.isNavigationBarHidden ?? false
    }
  }
  
  public func setNavIcon(title: String, color: UIColor, size: CGSize, position: NavIconPosition) -> UIButton {
    let btn = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    
    btn.titleLabel?.font = UIFont(name: "OpenSans-Light", size: 20)
    btn.setTitle(title, for: .normal)
    btn.setTitleColor(color, for: .normal)

    let btnBar = UIBarButtonItem(customView: btn)
    
    switch position {
    case .right:
      if navigationItem.rightBarButtonItems == nil {
        navigationItem.rightBarButtonItems = [UIBarButtonItem]()
      }
      
      navigationItem.rightBarButtonItems?.append(btnBar)
    case .left:
      if navigationItem.leftBarButtonItems == nil {
        navigationItem.leftBarButtonItems = [UIBarButtonItem]()
      }

      navigationItem.leftBarButtonItems?.append(btnBar)
    }
    
    return btn
  }
  
  public func setNavIcon(
    imageName: String,
    size: CGSize,
    position: NavIconPosition) -> UIButton {
    
    let btn = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    btn.setImage(UIImage(named: imageName), for: .normal)
    
    let btnBar = UIBarButtonItem(customView: btn)
    
    switch position {
    case .right:
      if navigationItem.rightBarButtonItems == nil {
        navigationItem.rightBarButtonItems = [UIBarButtonItem]()
      }
      
      navigationItem.rightBarButtonItems?.append(btnBar)
    case .left:
      if navigationItem.leftBarButtonItems == nil {
        navigationItem.leftBarButtonItems = [UIBarButtonItem]()
      }
      
      navigationItem.leftBarButtonItems?.append(btnBar)
    }
    
    return btn
  }
  
  public func setNavHeaderTitle(title: String, color: UIColor = UIColor.white) {
    self.navigationItem.title = title
    
    let navBarFont = UIFont(name: "Montserrat-Regular", size: 19)
    
    let navBarAttributesDictionary: [String: AnyObject]? = [
      NSForegroundColorAttributeName: color,
      NSFontAttributeName: navBarFont!
    ]
    
    navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
  }
  
  public func setNavHeaderIcon(imageName: String, size: CGSize) {
    let titleView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    titleView.image = UIImage(named: imageName)
    titleView.contentMode = .scaleAspectFit
    self.navigationItem.titleView = titleView
  }
  
  public func setNavBarColor(color: UIColor) {
    navigationController?.navigationBar.barStyle = .black
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.barTintColor = color
  }
}
