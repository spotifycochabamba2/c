//
//  CameraRetakeVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class CameraRetakeVC: UIViewController {
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.contentMode = .scaleAspectFit
      imageView.image = image
    }
  }
  var image: UIImage?
  var number: ProducePhotoNumber?
  var pictureTaken: (UIImage, ProducePhotoNumber) -> Void = {_,_ in }
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true)
  }
  
  @IBAction func retakeButtonTouched() {
    performSegue(withIdentifier: Storyboard.CameraRetakeToCamera, sender: nil)
  }
  
  func dismissWith(image: UIImage, number: ProducePhotoNumber) {
    dismiss(animated: true) { [weak self] in
      self?.pictureTaken(image, number)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.CameraRetakeToCamera {
      let vc = segue.destination as? CameraVC
      vc?.photoNumber = number
      vc?.pictureTaken = dismissWith
    }
  }
}










































