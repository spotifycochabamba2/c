//
//  ProduceImageVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ProduceImageVC: UIViewController {
  
  var containsCustomImage = false
  
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.backgroundColor = UIColor.hexStringToUIColor(hex: "#e1e3e5")
      imageView.image = UIImage(named: "cropswap-gray-logo")
    }
  }
  
  var image: UIImage? {
    get {
      return imageView.image
    }
    
    set {
      if let image = newValue {
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        containsCustomImage = true
      } else {
        imageView.image = UIImage(named: "cropswap-gray-logo")
        imageView.contentMode = .center
        containsCustomImage = false
      }
    }
  }
  
  var produceImageURL: String? {
    didSet {
      if let produceImageURL = produceImageURL {
        if let url = URL(string: produceImageURL) {
          imageView.contentMode = .scaleAspectFit
          imageView.sd_setImage(with: url)
          
          containsCustomImage = true
        }
      }
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
}

extension ProduceImageVC: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}






































