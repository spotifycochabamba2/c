//
//  DealSubmittedVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/12/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class DealSubmittedVC: UIViewController {
  
  var anotherUsername: String?
  var anotherPictureURL: String?
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var anotherImageView: UIImageView!
  @IBOutlet weak var myImageView: UIImageView!
  
  @IBOutlet weak var acceptButton: UIButton! {
    didSet {
      acceptButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    anotherImageView.layer.cornerRadius = 50
    anotherImageView.layer.borderColor = UIColor.clear.cgColor
    anotherImageView.layer.masksToBounds = true
    
    myImageView.layer.cornerRadius = 50
    myImageView.layer.borderColor = UIColor.clear.cgColor
    myImageView.layer.masksToBounds = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    User.getUser { (result) in
      switch result {
      case .success(let user):
        if let url = URL(string: user.profilePictureURL ?? "") {
          DispatchQueue.main.async { [weak self] in
            self?.myImageView.sd_setImage(with: url)
          }
        }
      case .fail(let error):
        break
      }
    }
    
    if let url = URL(string: anotherPictureURL ?? "") {
      anotherImageView.sd_setImage(with: url)
    }

    descriptionLabel.text = "Once \(anotherUsername?.capitalized ?? "") approves the deal, we will send you an alert to set a meet up spot."
    
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    acceptButton.layer.borderWidth = 1
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
  }
  
  @IBAction func acceptButtonTouched() {
    let makeDealVC = presentingViewController
    
    dismiss(animated: true) {
      DispatchQueue.main.async {
        makeDealVC?.dismiss(animated: true)
      }
    }
  }
  
}






















