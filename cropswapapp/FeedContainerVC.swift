//
//  FeedContainerVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/15/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class FeedContainerVC: UIViewController {
  var searchResultFeedVC: SearchResultFeedVC!
  var produceSearchController: UISearchController!
  
  @IBOutlet weak var mapContainer: UIView!
  @IBOutlet weak var producesContainer: UIView!
    
  var mapChild: FeedMapVC?
  var producesChild: FeedProducesVC?
  
  var isMapViewActive = false
  
  var leftBarButton: UIButton!
}

extension FeedContainerVC {
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.FeedContainerToFeedMap {
      let vc = segue.destination as? FeedMapVC
      mapChild = vc
    } else if segue.identifier == Storyboard.FeedContainerToFeedProduces {
      let vc = segue.destination as? FeedProducesVC
      vc?.didSelectProduce = didSelectProduce
      
      producesChild = vc
    } else if segue.identifier == Storyboard.FeedToProduce {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProduceContainerVC
      
      vc?.produce = sender as? Produce
    }
  }
  
  public func didSelectProduce(_ produce: Produce) {
    performSegue(withIdentifier: Storyboard.FeedToProduce, sender: produce)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    mapContainer.alpha = 0
    producesContainer.alpha = 1
    
    leftBarButton = setNavIcon(imageName: "map-icon", size: CGSize(width: 40, height: 40), position: .left)
    leftBarButton.addTarget(self, action: #selector(leftBarButtonTouched), for: .touchUpInside)
    
    let rightBarButton = setNavIcon(imageName: "search-icon", size: CGSize(width: 40, height: 40), position: .right)
    rightBarButton.addTarget(self, action: #selector(rightBarButtonTouched), for: .touchUpInside) // 17
    
    let distanceBarButton = setNavIcon(imageName: "distance-icon", size: CGSize(width: 40, height: 40), position: .right)
    distanceBarButton.addTarget(self, action: #selector(distanceBarButtonTouched), for: .touchUpInside)
    
    setNavHeaderIcon(imageName: "navbar-title-feed", size: CGSize(width: 124, height: 22))
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
    
    automaticallyAdjustsScrollViewInsets = false
    
    let storyboard = UIStoryboard(name: "SearchResultFeed", bundle: nil)
    searchResultFeedVC = storyboard.instantiateViewController(withIdentifier: "SearchResultFeedVC") as! SearchResultFeedVC
    
    searchResultFeedVC.view.frame = view.frame
    produceSearchController = UISearchController(searchResultsController: searchResultFeedVC)
    produceSearchController.searchBar.delegate = searchResultFeedVC
    produceSearchController.delegate = searchResultFeedVC
    produceSearchController.dimsBackgroundDuringPresentation = true
    produceSearchController.searchBar.sizeToFit()
    definesPresentationContext = false
  }
}

extension FeedContainerVC {
  func distanceBarButtonTouched() {
    performSegue(withIdentifier: Storyboard.FeedContainerToDistanceControl, sender: nil)
  }
  
  func leftBarButtonTouched() {
    isMapViewActive = !isMapViewActive
    
    leftBarButton.isEnabled = false
    
    if isMapViewActive {
      UIView.animate(withDuration: 0.5, animations: { [weak self] in
        self?.producesContainer.alpha = 0
        }, completion: { [weak self] (finished) in
          if finished {
            DispatchQueue.main.async {
              self?.mapContainer.alpha = 1
              self?.leftBarButton.isEnabled = true
            }
          }
        })
      leftBarButton.setImage(UIImage(named: "feed-icon"), for: .normal)
    } else {
      UIView.animate(withDuration: 0.5, animations: { [weak self] in
        self?.mapContainer.alpha = 0
        }, completion: { [weak self] (finished) in
          if finished {
            DispatchQueue.main.async {
              self?.producesContainer.alpha = 1
              self?.leftBarButton.isEnabled = true
            }
          }
        })
      leftBarButton.setImage(UIImage(named: "map-icon"), for: .normal)
    }
  }
  
  func rightBarButtonTouched() {
    //    navigationController?.pushViewController(produceSearchController, animated: true)
    print(presentedViewController)
    print(presentingViewController)
    
    tabBarController?.present(produceSearchController, animated: true) {
      
    }
  }
}

































