//
//  ProduceImageZoomableVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ProduceImageZoomableVC: UIViewController {
  
  @IBOutlet weak var closeButton: UIButton!
  
  var hideCloseButton = true
  var customImage: UIImage?
  
  @IBOutlet weak var produceScrollView: UIScrollView!
  @IBOutlet weak var produceImageView: UIImageView! {
    didSet {
      produceImageView.contentMode = .scaleAspectFit
      produceImageView.backgroundColor = .black
    }
  }
  
  @IBAction func closeButtonTouched() {
    dismiss(animated: true)
  }
  
}

extension ProduceImageZoomableVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    closeButton.isHidden = hideCloseButton
    view.backgroundColor = .black
    produceScrollView.minimumZoomScale = 1.0
    produceScrollView.maximumZoomScale = 6.0
    produceScrollView.contentSize = produceImageView.frame.size
    
    if let image = customImage {
      produceImageView.image = image
    }
  }
}

extension ProduceImageZoomableVC: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return produceImageView
  }
}
















