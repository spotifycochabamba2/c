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
  
  @IBOutlet var imagePageControl: UIPageControl!
  @IBOutlet weak var closeButton: UIButton!
  
  var images = [UIImage]()
  var imagesURLStrings = [String]()
  var imageViewControllers = [UIViewController]()
  
  var isImagesURLStrings = false
  
  var pageContainer: UIPageViewController!
  var currentIndex = 0
  var pendingIndex = 0
  
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
    
    imagePageControl.isUserInteractionEnabled = false
    imagePageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
    
    imagePageControl.currentPageIndicatorTintColor = UIColor.white
    imagePageControl.pageIndicatorTintColor = UIColor.hexStringToUIColor(hex: "#ab999d")
    
    pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    pageContainer.dataSource = self
    pageContainer.delegate = self
    
    if isImagesURLStrings {
      imagesURLStrings.forEach {
        if let url = URL(string: $0) {
          let vc = createImageViewController()
          vc.produceImageView.image = UIImage()
          vc.produceImageView.sd_setImage(with: url)
          
          imageViewControllers.append(vc)
        }
      }
    } else {
      images.forEach {
        let vc = createImageViewController($0)
        imageViewControllers.append(vc)
      }
    }
    
    imagePageControl.isHidden = imageViewControllers.count <= 1
    imagePageControl.numberOfPages = imageViewControllers.count
    
    if imageViewControllers.count > 0 {
      pageContainer.setViewControllers([imageViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
    }

//    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
//    pageContainer.view.addGestureRecognizer(pinchGesture)
    
    view.addSubview(pageContainer.view)
    view.backgroundColor = .black
    view.bringSubview(toFront: closeButton)
//    view.bringSubview(toFront: nextPictureButton)
//    view.bringSubview(toFront: previousPictureButton)
    view.bringSubview(toFront: imagePageControl)
    
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
  
  func createImageViewController() -> ProduceImageZoomableVC {
    let produceImage = getProduceImageViewController(name: "ProduceImageZoomableVC") as! ProduceImageZoomableVC
    _ = produceImage.view
//    produceImage.produceImageView.image = image
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
      imagePageControl.currentPage = pendingIndex
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





























