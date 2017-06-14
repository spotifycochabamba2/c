//
//  ChooseUnitVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/27/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ChooseUnitVC: UIViewController {
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  var typeSelected: String?
  
  var chooseUnitListVC: ChooseUnitListVC?
  var didSelectUnit: (String) -> Void = { _ in }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    chooseUnitListVC = segue.destination as? ChooseUnitListVC
    chooseUnitListVC?.typeSelected = typeSelected
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
    if let chooseUnitListVC = chooseUnitListVC {
      if let stateSelected = chooseUnitListVC.unitSelected {
        didSelectUnit(stateSelected)
      }
    }
    
    dismiss(animated: true)
  }
}

































