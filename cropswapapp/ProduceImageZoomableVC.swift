//
//  ProduceImageZoomableVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ProduceImageZoomableVC: UIViewController {
  @IBOutlet weak var produceScrollView: UIScrollView!
  @IBOutlet weak var produceImageView: UIImageView! {
    didSet {
      produceImageView.contentMode = .scaleAspectFit
      produceImageView.backgroundColor = .black
    }
  }
}

extension ProduceImageZoomableVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    produceScrollView.minimumZoomScale = 1.0
    produceScrollView.maximumZoomScale = 6.0
    produceScrollView.contentSize = produceImageView.frame.size
  }
}

extension ProduceImageZoomableVC: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return produceImageView
  }
}
