//
//  ChooseStateVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/19/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ChooseStateVC: UIViewController {
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  var didSelectState: (String) -> Void = { _ in }
  
  var chooseStateListVC: ChooseStateListVC?
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    chooseStateListVC = segue.destination as? ChooseStateListVC
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  }
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true)
  }
  
  @IBAction func acceptButtonTouched() {
    if let chooseStateListVC = chooseStateListVC {
      if let stateSelected = chooseStateListVC.stateSelected {
        didSelectState(stateSelected)
      }
    }
    
    dismiss(animated: true)
  }
  
}




























