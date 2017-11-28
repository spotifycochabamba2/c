//
//  CameraVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {
  
  var produceId: String?
  var photoNumber: ProducePhotoNumber?
  
  var pictureTaken: (UIImage, ProducePhotoNumber) -> Void = {_,_ in}
  var pictureTaken2: (UIImage) -> Void = {_ in }
  var cancelled: () -> Void = {}

  @IBOutlet var cameraView: CameraView!
  var cameraController = Camera()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    cameraController.startSession()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    cameraController.stopSession()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      if try cameraController.setupSession() {
        cameraView.setSession(cameraController.captureSession)
      }
    } catch {

    }

  }
  
  @IBAction func switchButtonTouched() {
    do {
      try cameraController.switchCameras()
    } catch {

    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.CameraToCameraConfirm {
      let vc = segue.destination as? CameraConfirmVC
      
      vc?.image = sender as? UIImage
      vc?.produceId = produceId
      vc?.photoNumber = photoNumber
      vc?.pictureTaken = pictureTakenForCameraVC
    }
  }
  
  func pictureTakenForCameraVC(image: UIImage, number: ProducePhotoNumber) {
    
    dismiss(animated: true) { [weak self] in
      self?.pictureTaken(image, number)
    }
    
  }
  
  func pictureTakenForCameraVC2(image: UIImage) {
    
    dismiss(animated: true) { [weak self] in
      self?.pictureTaken2(image)
    }
    
  }

  
  @IBAction func takeButtonTouched(_ sender: AnyObject) {
    
    cameraController.captureStillImage { [weak self] (image) in
      let deviceSize = UIScreen.main.bounds.size
      let resizedImage = image.resizeImage(withTargerSize: deviceSize)
      
      self?.performSegue(withIdentifier: Storyboard.CameraToCameraConfirm, sender: resizedImage)
    }

  }
  
  
  @IBAction func cancelButtonTouched() {
    self.cancelled()
    dismiss(animated: true)
  }
}






















































