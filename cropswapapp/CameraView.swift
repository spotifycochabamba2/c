//
//  CameraView.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setupView()
  }
  
  override class var layerClass : AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
  
  func getSession() -> AVCaptureSession? {
    let videoLayer = self.layer as? AVCaptureVideoPreviewLayer
    return videoLayer?.session
  }
  
  func setSession(_ session: AVCaptureSession) {
    let videoLayer = self.layer as? AVCaptureVideoPreviewLayer
    videoLayer?.session = session
  }
  
  
  func setupView() {
    let videoLayer = self.layer as? AVCaptureVideoPreviewLayer
    videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
  }
}

