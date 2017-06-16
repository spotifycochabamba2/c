//
//  DistanceControlVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/15/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class DistanceControlVC: UIViewController {
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  @IBOutlet weak var slider: UISlider!
  
  
  @IBOutlet weak var valueLabel: UILabel!
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  @IBAction func slidedValueChanged(_ sender: AnyObject) {
    let value = lroundf(slider.value)
    valueLabel.text = "\(value)"
    
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
    dismiss(animated: true)
  }
}
