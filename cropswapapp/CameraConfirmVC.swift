//
//  CameraConfirmVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class CameraConfirmVC: UIViewController {
  var image: UIImage?
  var photoNumber: ProducePhotoNumber?
  var produceId: String?
  
  var pictureTaken: (UIImage, ProducePhotoNumber) -> Void = { _, _ in}
  
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.image = image
      imageView.contentMode = .scaleAspectFit
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func acceptButtonTouched(_ sender: AnyObject) {
    guard
      let image = image,
      let photoNumber = photoNumber
    else {
      let alert = UIAlertController(title: "Error", message: "No Image or Image number valid Found", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alert, animated: true)
      return
    }
    
    dismiss(animated: true) { [weak self] in
      self?.pictureTaken(image, photoNumber)
    }
  }
  
  @IBAction func cancelButtonTouched(_ sender: AnyObject) {
    dismiss(animated: true)
  }
}














































