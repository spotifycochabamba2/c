//
//  LocationNoticeVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/20/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class LocationNoticeVC: UIViewController {
  
  @IBOutlet weak var upperView: UIView!
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var letsDoItButton: UIButton!
  
  @IBAction func letsDoItButtonTouched() {
    performSegue(withIdentifier: Storyboard.LocationNoticeToYourLocation, sender: nil)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
//    modalPresentationCapturesStatusBarAppearance = false
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
  }
  
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    view.backgroundColor = .clear
    
    letsDoItButton.makeMeBordered()
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
  }
}


























