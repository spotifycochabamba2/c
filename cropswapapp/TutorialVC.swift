//
//  TutorialVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class TutorialVC: UIViewController {
  
  @IBOutlet weak var skipNextView: UIView!
  @IBOutlet weak var pageControl: UIPageControl!
  var pageContainer: UIPageViewController!
  var currentIndex = 0
  var pendingIndex = 0
  var tutorialImageViewControllers = [UIViewController]()
  
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    pageControl.isUserInteractionEnabled = false
    pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
    
    pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    pageContainer.dataSource = self
    pageContainer.delegate = self
    
    let firstTutorialVC = getProduceImageViewController(name: "FirstTutorial")
    let secondTutorialVC = getProduceImageViewController(name: "SecondTutorial")
    let thirdTutorialVC = getProduceImageViewController(name: "ThirdTutorial")
    
    tutorialImageViewControllers.append(firstTutorialVC)
    tutorialImageViewControllers.append(secondTutorialVC)
    tutorialImageViewControllers.append(thirdTutorialVC)
    
    pageContainer.setViewControllers([firstTutorialVC], direction: .forward, animated:false)
  }
  
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    skipNextView.layer.shadowOffset = CGSize(width: 0, height: 0);
    skipNextView.layer.shadowRadius = 2;
    skipNextView.layer.shadowColor = UIColor.black.cgColor
    skipNextView.layer.shadowOpacity = 0.3;
    
    pageContainer.view.frame = view.bounds
    view.addSubview(pageContainer.view)
    view.bringSubview(toFront: skipNextView)
  }
  
  @IBAction func nextButtonTouched() {
    if currentIndex < (tutorialImageViewControllers.count - 1) {
      currentIndex += 1
      pageControl.currentPage = currentIndex
      pageContainer.setViewControllers([tutorialImageViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
    } else {
      skipButtonTouched()
    }
  }
  
  @IBAction func skipButtonTouched() {
    performSegue(withIdentifier: Storyboard.TutorialToLocationNotice, sender: nil)
  }
  
  func getProduceImageViewController(name: String) -> UIViewController {
    return UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "\(name)")
  }
}


extension TutorialVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    pendingIndex = tutorialImageViewControllers.index(of: pendingViewControllers.first!)!
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      currentIndex = pendingIndex
      pageControl.currentPage = pendingIndex
    }
  }
  
  public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return tutorialImageViewControllers.count
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let currentIndex = tutorialImageViewControllers.index(of: viewController)
    
    if currentIndex == 0 {
      return nil
    }
    
    let previousIndex = abs((currentIndex! - 1) % tutorialImageViewControllers.count)
    return tutorialImageViewControllers[previousIndex]
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let currentIndex = tutorialImageViewControllers.index(of: viewController)
    
    if currentIndex == (tutorialImageViewControllers.count - 1) {
      return nil
    }
    
    let nextIndex = abs((currentIndex! + 1) % tutorialImageViewControllers.count)
    return tutorialImageViewControllers[nextIndex]
  }
}













































