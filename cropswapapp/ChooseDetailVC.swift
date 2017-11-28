//
//  ChooseDetailVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/17/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ChooseDetailVC: UIViewController {
  var chooseDetailListVC: ChooseDetailListVC?
  
  var didSelectTags: ([(String, Bool, Int, String)]) -> Void = { _ in }
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    chooseDetailListVC = segue.destination as? ChooseDetailListVC
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
    if let chooseDetailListVC = chooseDetailListVC {
      didSelectTags(chooseDetailListVC.tags.filter { $0.1  == true })
    }
    
    dismiss(animated: true)
  }
}






























