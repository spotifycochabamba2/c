//
//  Camera.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Camera: NSObject {
  
  var captureSession = AVCaptureSession()
  var activeVideoInput = AVCaptureDeviceInput()
  var imageOutput = AVCapturePhotoOutput()
  var callback: (UIImage) -> Void = { _ in }
  
  func switchCameras() throws {
    
    let desiredCameraPosition = getDesiredCameraPosition(by: activeVideoInput)
    
    let cameraAvailable = getCamera(byPosition: desiredCameraPosition)
    
    setCamera(with: cameraAvailable)
  }
  
  func getDesiredCameraPosition(by videoInput:AVCaptureDeviceInput?) -> AVCaptureDevicePosition {
    let currentCameraPosition = videoInput?.device.position
    var desiredCameraPosition = AVCaptureDevicePosition.back
    
    if currentCameraPosition == .front {
      desiredCameraPosition = .back
    } else if currentCameraPosition == .back {
      desiredCameraPosition = .front
    }
    
    return desiredCameraPosition
  }
  
  func getCamera(byPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
    let deviceTypes: [AVCaptureDeviceType] = [.builtInDuoCamera, .builtInTelephotoCamera,.builtInWideAngleCamera]
    let session = AVCaptureDeviceDiscoverySession(
      deviceTypes: deviceTypes,
      mediaType: AVMediaTypeVideo,
      position: position
    )
    
    if let session = session {
      if let devices = session.devices {
        for device in devices {
          if device.position == position {
            return device
          }
        }
      }
    }
    
    return nil
  }
  
  func setCamera(with camera: AVCaptureDevice?) {
    if let cameraAvailable = camera {
      let videoInput = try? AVCaptureDeviceInput(device: cameraAvailable)
      
      if let videoInput = videoInput {
        self.captureSession.beginConfiguration()
        self.captureSession.removeInput(self.activeVideoInput)
        
        if self.captureSession.canAddInput(videoInput) {
          self.captureSession.addInput(videoInput)
          self.activeVideoInput = videoInput
        } else {
          self.captureSession.addInput(self.activeVideoInput)
        }
        
        self.captureSession.commitConfiguration()
      }
    }
  }
  
  func startSession() {
    if !captureSession.isRunning {
      DispatchQueue.main.async { [weak self] in
        self?.captureSession.startRunning()
      }
    }
  }
  
  func stopSession() {
    if captureSession.isRunning {
      DispatchQueue.main.async { [weak self] in
        self?.captureSession.stopRunning()
      }
    }
  }
  
  func setupSession() throws -> Bool {
    captureSession.sessionPreset = AVCaptureSessionPresetHigh
    
    // 1.- setting up the camera device
    let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
    
    if let videoInput = videoInput {
      if captureSession.canAddInput(videoInput) {
        captureSession.addInput(videoInput)
        activeVideoInput = videoInput
      }
    } else {
      return false
    }
    
    
    if captureSession.canAddOutput(imageOutput) {
      captureSession.addOutput(imageOutput)
    }
    
    return true
  }
  
  
  func captureStillImage(completion: @escaping (UIImage) -> Void) {
    callback = completion
    let connection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
    
    if let connection = connection,
      connection.isVideoOrientationSupported {
      connection.videoOrientation = .portrait
    }
    
    
    let settings = AVCapturePhotoSettings()
    let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
    let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                         kCVPixelBufferWidthKey as String: 160,
                         kCVPixelBufferHeightKey as String: 160]
    settings.previewPhotoFormat = previewFormat
    imageOutput.capturePhoto(with: settings, delegate: self)
  }
  
}

extension Camera: AVCapturePhotoCaptureDelegate {
  func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    
    
    if
      let sampleBuffer = photoSampleBuffer,
      let previewBuffer = previewPhotoSampleBuffer,
      let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
      
      
      
      var capturedImage = UIImage(data: dataImage)
      
      let cameraPosition = activeVideoInput.device.position
      
      // si la camara es la frontal,
      // hacemos un flipping a la imagen
      if let image = capturedImage,
        cameraPosition == .front {
        
        capturedImage = UIImage(
          cgImage: image.cgImage!,
          scale: image.scale,
          orientation: UIImageOrientation.leftMirrored
        )
        
      }
      
      DispatchQueue.main.async { [weak self] in
        print(capturedImage)
        if let image = capturedImage {
          self?.callback(image)
        }
      }
    }
    
  }
}



































