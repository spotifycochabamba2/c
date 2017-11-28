//
//  InstagramLoginVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/2/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class InstagramVC: UIViewController {
  @IBOutlet weak var webView: UIWebView!
  var isCodePresent = false
  var wasLoggedIn = false
  var onlyForGettingPictures = false
  var userIdOnlyForGettingPictures: String?
  
  var loggedSuccessfully: (Bool) -> Void = { _ in  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if !onlyForGettingPictures {
      User.logout()
    }
    
    webView.scrollView.bounces = false
    webView.delegate = self
    

    if let url = URL(string: Constants.Instagram.authURL) {
      let request = URLRequest(url: url)
      
      webView.loadRequest(request)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  @IBAction func closeButtonTouched() {
    dismiss(animated: true, completion: nil)
  }
  
  
}

extension InstagramVC: UIWebViewDelegate {
  func webViewDidStartLoad(_ webView: UIWebView) {
    SVProgressHUD.show()
  }
  
  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

    if let code = Utils.getQueryStringParameter(url: request.url, param: "code") {
      isCodePresent = true
      
      var userFound: User? = nil
      var isNewUser: Bool = false
      
      var firebaseToken: String? = nil
      
      Ax.serial(tasks: [
        { done in
          User.getFirebaseToken(with: code) { result in
            switch result {
            case .success(let data):
              userFound = data["user"] as? User
              firebaseToken = data["firebaseToken"] as? String
              done(nil);
              break
            case .fail(let error):
              done(error)
              break
            }
          }
        },
        { [weak self] done in
          guard
            let user = userFound,
            let firebaseToken = firebaseToken
          else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user or firebase token valid."])
            done(error)
            return
          }
          
          if self?.onlyForGettingPictures ?? false,
             let userId = self?.userIdOnlyForGettingPictures,
             let instagramId = user.instagramId,
             let instagramToken = user.instagramToken
          {
            User.update(
              byUserId: userId,
              withInstagramId: instagramId,
              andInstagramToken: instagramToken,
              completion: { (error) in
                done(error)
            })
          } else {
            User.login(with: user, firebaseToken: firebaseToken) { result in
              switch result {
              case .success(let result):
                let userReturned = result["user"] as? User
                let isNew = result["isNew"] as? Bool
                
                userFound = userReturned
                isNewUser = isNew ?? false
                
                done(nil)
                break
              case .fail(let error):
                done(error)
                break
              }
            }
          }
        }
      ], result: { error in
        if let error = error {
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alert, animated: true)
        } else {
          if userFound != nil {
            self.wasLoggedIn = true
            DispatchQueue.main.async {
              self.dismiss(animated: true) {
                DispatchQueue.main.async {
                  self.loggedSuccessfully(isNewUser)
                }
              }
            }
          } else {
            let alert = UIAlertController(title: "Error", message: "No user found.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            DispatchQueue.main.async {
              self.present(alert, animated: true)
            }
          }
        }
      })

      return false
    }

    return true
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
    let jsonString = webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].getElementsByTagName('pre')[0].innerHTML")
    if let data = jsonString?.data(using: .utf8) {
      let dict = try? JSONSerialization.jsonObject(with: data, options: [])
      if let dict = dict as? [String: Any],
        let _ = dict["error_type"] as? String
//        errorType == "OAuthForbiddenException"
      {
        User.logout()
      }
    }
    
    if !isCodePresent {
      SVProgressHUD.dismiss()
    }
  }
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    if !isCodePresent {
      SVProgressHUD.dismiss()
    }
  }
}


























