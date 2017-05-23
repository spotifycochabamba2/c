//
//  PhotoViewerVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/19/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit



class PhotoViewerVC: UIViewController {
  let minimumScale = 0.5
  let maximunScale = 6.0
  
  @IBOutlet weak var closeButton: UIButton!
  
  var images = [UIImage]()
  var imageViewControllers = [UIViewController]()
  
  var pageContainer: UIPageViewController!
  var currentIndex = 0
  var pendingIndex = 0
  
  @IBOutlet weak var nextPictureButton: UIButton!
  @IBOutlet weak var previousPictureButton: UIButton!
  
  var pictureIndexLeft: (Int) -> Void = { _ in }
  
  @IBAction func nextPictureButtonTouched() {
    if currentIndex < (imageViewControllers.count - 1) {
      currentIndex += 1
      pageContainer.setViewControllers([imageViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
    }
  }
  
  @IBAction func previousPictureButtonTouched() {
    if currentIndex > 0 {
      currentIndex -= 1
      pageContainer.setViewControllers([imageViewControllers[currentIndex]], direction: .reverse, animated: true, completion: nil)
    }
  }
  
  
  @IBAction func closeButtonTouched() {
    pictureIndexLeft(currentIndex)
    dismiss(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    
    pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    pageContainer.dataSource = self
    pageContainer.delegate = self
    
    switch images.count {
    case 1:
      let image1 = images[0]
      
      let vc1 = createImageViewController(image1)
      imageViewControllers.append(vc1)
    case 2:
      let image1 = images[0]
      let image2 = images[1]
      
      let vc1 = createImageViewController(image1)
      let vc2 = createImageViewController(image2)
      imageViewControllers.append(vc1)
      imageViewControllers.append(vc2)
    case 3:
      let image1 = images[0]
      let image2 = images[1]
      let image3 = images[2]
      
      let vc1 = createImageViewController(image1)
      let vc2 = createImageViewController(image2)
      let vc3 = createImageViewController(image3)
      imageViewControllers.append(vc1)
      imageViewControllers.append(vc2)
      imageViewControllers.append(vc3)
    case 4:
      let image1 = images[0]
      let image2 = images[1]
      let image3 = images[2]
      let image4 = images[3]
      
      let vc1 = createImageViewController(image1)
      let vc2 = createImageViewController(image2)
      let vc3 = createImageViewController(image3)
      let vc4 = createImageViewController(image4)
      imageViewControllers.append(vc1)
      imageViewControllers.append(vc2)
      imageViewControllers.append(vc3)
      imageViewControllers.append(vc4)
    case 5:
      let image1 = images[0]
      let image2 = images[1]
      let image3 = images[2]
      let image4 = images[3]
      let image5 = images[4]
      
      let vc1 = createImageViewController(image1)
      let vc2 = createImageViewController(image2)
      let vc3 = createImageViewController(image3)
      let vc4 = createImageViewController(image4)
      let vc5 = createImageViewController(image5)
      imageViewControllers.append(vc1)
      imageViewControllers.append(vc2)
      imageViewControllers.append(vc3)
      imageViewControllers.append(vc4)
      imageViewControllers.append(vc5)
    default:
      break
    }
    
    if imageViewControllers.count > 0 {
    pageContainer.setViewControllers([imageViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
    }

//    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
//    pageContainer.view.addGestureRecognizer(pinchGesture)
    
    view.addSubview(pageContainer.view)
    view.backgroundColor = .black
    view.bringSubview(toFront: closeButton)
    view.bringSubview(toFront: nextPictureButton)
    view.bringSubview(toFront: previousPictureButton)
    
//    pageControl.numberOfPages = tutorialViewControllers.count
//    pageControl.currentPage = 0
  }
  
  
  
//  func handlePinch(recognizer: UIPinchGestureRecognizer) {
//    if recognizer.state == .began {
//      
//    } else if recognizer.state == .changed {
//      
//    }
    
//    if recognizer.state == .began ||
//      recognizer.state == .changed {
//      let layer = imageViewControllers[currentIndex].view?.layer
//      let currentScale = layer?.value(forKeyPath: "transform.scale.x")
//    }
//  }
  
//  var translation = CGPoint.zero
  
  
  
//  func pan(gesture: UIPanGestureRecognizer) {
//    print(gesture.state)
//    var currentTranslation = CGPoint.zero
//    var currentScale: CGFloat = 0
//    
//    if gesture.state == .began {
//      currentTranslation = translation
//      currentScale = pageContainer.view.frame.width / pageContainer.view.bounds.size.width
//    } else if gesture.state == .ended ||
//      gesture.state == .changed {
//      
//      let innerTranslation = gesture.translation(in: pageContainer.view)
//      
//      translation.x = innerTranslation.x + currentTranslation.x
//      translation.y = innerTranslation.y + innerTranslation.y
//      
//      let transform1 = CGAffineTransform.init(translationX: translation.x, y: translation.y)
//      let transform2 = CGAffineTransform.init(scaleX: currentScale, y: currentScale)
//      let transform3 = transform1.concatenating(transform2)
//      
//      pageContainer.view.transform = transform3
//    }
//  }
  
  func createImageViewController(_ image: UIImage) -> ProduceImageZoomableVC {
    let produceImage = getProduceImageViewController(name: "ProduceImageZoomableVC") as! ProduceImageZoomableVC
    _ = produceImage.view
    produceImage.produceImageView.image = image
//    produceImage.produceImageView.backgroundColor = .black
//    produceImageTwo.produceImageURL = secondPictureURL
    return produceImage
  }
  
  func getProduceImageViewController(name: String) -> UIViewController {
    return UIStoryboard(name: "Produce", bundle: nil).instantiateViewController(withIdentifier: "\(name)")
  }
}


extension PhotoViewerVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    pendingIndex = imageViewControllers.index(of: pendingViewControllers.first!)!
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      currentIndex = pendingIndex
    }
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return imageViewControllers.count
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let currentIndex = imageViewControllers.index(of: viewController)
    
    if currentIndex == 0 {
      return nil
    }
    
    let previousIndex = abs((currentIndex! - 1) % imageViewControllers.count)
    return imageViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let currentIndex = imageViewControllers.index(of: viewController)
    
    if currentIndex == (imageViewControllers.count - 1) {
      return nil
    }
    
    let nextIndex = abs((currentIndex! + 1) % imageViewControllers.count)
    return imageViewControllers[nextIndex]
  }
}





























