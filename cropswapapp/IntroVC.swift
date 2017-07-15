//
//  IntroVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class IntroVC: UIViewController {
  
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var instagramButton: UIButton!
  
  var wentToLoginScreen = false
  var wentToInstagramScreen = false
  var wentToSignupScreen = false
}

extension IntroVC {
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    signupButton.applyShadowedBordered()
    loginButton.applyShadowedBordered()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBarIsHidden = true

    instagramButton.makeMeBordered(color: .white)
    signupButton.makeMeBordered(color: .white)
    loginButton.makeMeBordered(color: .white)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationBarIsHidden = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    SVProgressHUD.show()
    
    if User.currentUser != nil,
       !wentToLoginScreen,
       !wentToSignupScreen,
       !wentToInstagramScreen
    {
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: Storyboard.IntroToHome, sender: nil)
      }
    } else {
      SVProgressHUD.dismiss()
    }
  }
}

extension IntroVC {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.IntroToLogin {
      let vc = segue.destination as? LoginVC
      vc?.showSignupView = showSignupView
    } else if segue.identifier == Storyboard.IntroToSignup {
      let vc = segue.destination as? SignupVC
      vc?.showLoginView = showLoginView
    } else if segue.identifier == Storyboard.IntroToInstagram {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? InstagramVC
      print(vc)
      vc?.loggedSuccessfully = performSegueToHome
    }
  }
  
  func performSegueToHome(user: User) {
    performSegue(withIdentifier: Storyboard.IntroToHome, sender: user)
  }
  
  func showSignupView() {
    _ = navigationController?.popToViewController(self, animated: true)
    goToSignupView()
  }
  
  func showLoginView() {
    _ = navigationController?.popToViewController(self, animated: true)
    goToLoginView()
  }
}

extension IntroVC {
  @IBAction func goToLoginView() {
    wentToLoginScreen = true
    performSegue(withIdentifier: Storyboard.IntroToLogin, sender: nil)
  }
  
  @IBAction func goToSignupView() {
    wentToSignupScreen = true
    performSegue(withIdentifier: Storyboard.IntroToSignup, sender: nil)
  }
  
  @IBAction func instagramButtonTouched() {
    wentToInstagramScreen = true
    performSegue(withIdentifier: Storyboard.IntroToInstagram, sender: nil)
  }
}































