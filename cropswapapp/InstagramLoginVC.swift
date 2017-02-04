//
//  InstagramLoginVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/2/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class InstagramVC: UIViewController {
  @IBOutlet weak var webView: UIWebView!
  var isCodePresent = false
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.scrollView.bounces = false
    webView.delegate = self
    

    if let url = URL(string: Constants.Instagram.authURL) {
      let request = URLRequest(url: url)
      
      webView.loadRequest(request)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
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
    print(request.url)
    if Utils.getQueryStringParameter(url: request.url, param: "code") != nil {
//      request.url?.absoluteString
//      Optional("http://localhost:4040/instagram-callback?code=5c3dbad353a84e8da43428c699e4862c")
      isCodePresent = true
      return false
    }
    
    return true
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
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


























