//
//  IntroVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 1/30/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class IntroVC: UIViewController {
  
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var instagramButton: UIButton!

}

extension IntroVC {
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = true
    navigationController?.isNavigationBarHidden = true
    
    instagramButton.makeMeBordered(color: .white)
    signupButton.makeMeBordered(color: .white)
    loginButton.makeMeBordered(color: .white)
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
    }
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
    performSegue(withIdentifier: Storyboard.IntroToLogin, sender: nil)
  }
  
  @IBAction func goToSignupView() {
    performSegue(withIdentifier: Storyboard.IntroToSignup, sender: nil)
  }
  
  @IBAction func instagramButtonTouched() {
    performSegue(withIdentifier: Storyboard.IntroToInstagram, sender: nil)
  }
}































