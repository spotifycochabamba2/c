//
//  MyFeedVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class FeedVC: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  
  let cellIdentifier = "FeedCellId"
  
  var produces = [Produce]()
  
  var time = Date()
  var limitProducesBrought: UInt = 11
  
  var getNewProducesHandlerId: UInt = 0
  var getRemovedProducesHandlerId: UInt = 0
  var getUpdatedProducesHandlerId: UInt = 0
  
  var ignoreItems = true
  
  // used for getting paginated data
  var isGettingPaginatedDataFromServer = false
  
  // used for getting data for the first time
  var isGettingFirstDataFromServer = true
  
  var dataGotFromServer = false
  
  deinit {
    User.stopListeningToGetProducesByListeningAddedNewOnes(handlerId: getNewProducesHandlerId, fromTime: time)
    User.stopListeningToGetProducesByListeningRemovedOnes(handlerId: getRemovedProducesHandlerId)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.FeedToProduce {
      
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProduceContainerVC
      
      vc?.produce = sender as? Produce
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if !dataGotFromServer {
      DispatchQueue.main.async {
        SVProgressHUD.show()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    
    SVProgressHUD.show()
    User.getProducesOnce(byLimit: limitProducesBrought) { [weak self] (produces) in
      print(produces.count)
      SVProgressHUD.dismiss()
      
      self?.dataGotFromServer = true
      
      self?.ignoreItems = false
      
      self?.produces = produces
      self?.isGettingFirstDataFromServer = false
      
      if let this = self {
        DispatchQueue.main.async {
          UIView.transition(
            with: this.collectionView,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: {
              this.collectionView.reloadData()
            },
            completion: nil
          )
        }
      }
    }

    
    time = Date()
    getNewProducesHandlerId = User.getProducesByListeningAddedNewOnes(fromTime: time) { [unowned self] (newProduce) in
      print(newProduce)
      self.collectionView.performBatchUpdates({
        
        self.produces.insert(newProduce, at: 0)
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.insertItems(at: [indexPath])
        }, completion: { (finished) in
          
          
          
      })
    }
    
    getRemovedProducesHandlerId = User.getProducesByListeningRemovedOnes(completion: { [unowned self] (produceIdRemoved) in
      let produceIndex = self.produces.index(where: { (produce) -> Bool in
        return produce.id == produceIdRemoved
      })
      
      if let produceIndex = produceIndex {
        self.collectionView.performBatchUpdates({
          self.produces.remove(at: produceIndex)
          let indexPath = IndexPath(item: produceIndex, section: 0)
          self.collectionView.deleteItems(at: [indexPath])
          }, completion: nil)
      }
      })
    
    
    getUpdatedProducesHandlerId = User.getProducesByListeningUpdatedOnes(completion: { (produceUpdated) in
      print(produceUpdated)
      let produceIndex = self.produces.index(where: { (produce) -> Bool in
        return produce.id == produceUpdated.id
      })
      
      if let produceIndex = produceIndex {
        self.collectionView.performBatchUpdates({
          self.produces[produceIndex] = produceUpdated
          let indexPath = IndexPath(item: produceIndex, section: 0)
          self.collectionView.reloadItems(at: [indexPath])
          }, completion: nil)
      }
    })
    
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    
    _ = setNavIcon(imageName: "search-icon", size: CGSize(width: 17, height: 17), position: .right)
    
    setNavHeaderIcon(imageName: "navbar-title-feed", size: CGSize(width: 124, height: 22))
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
    
    automaticallyAdjustsScrollViewInsets = false
    
    collectionView.alwaysBounceVertical = true
  }
}

extension FeedVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FeedCell

    let produce = produces[indexPath.row]
    
    cell.producePictureURL = produce.firstPictureURL ?? ""
    cell.produceName = produce.name
    cell.price = produce.price
    cell.distance = 0
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return produces.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 13.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(13, 13, 13, 13)
  }

  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.frame.size.width / 2) - 20, height: (250))
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let produce = produces[indexPath.row]
    
    performSegue(withIdentifier: Storyboard.FeedToProduce, sender: produce)
  }
}


extension FeedVC {
  
  func checkHasScrolledToBottom() {
    let bottomEdge = collectionView.contentOffset.y + collectionView.frame.size.height
    
    if bottomEdge >= collectionView.contentSize.height {
      if produces.count > 0 && !isGettingPaginatedDataFromServer && !isGettingFirstDataFromServer {
        print("getting paginated data......")
        let lastProduceId = produces[produces.count - 1].id
        isGettingPaginatedDataFromServer = true
        SVProgressHUD.show()
        User.getProducesOnce(byLimit: limitProducesBrought, startingFrom: lastProduceId, completion: { [unowned self] (broughtProduces) in
          DispatchQueue.main.async {
            SVProgressHUD.dismiss()
          }
          self.isGettingPaginatedDataFromServer = false
          
          self.collectionView.performBatchUpdates({
            
            var indexToInsert = self.produces.count - 1
            var newIndexPaths = [IndexPath]()
            
            broughtProduces.forEach { _ in
              indexToInsert += 1
              newIndexPaths.append(IndexPath(item: indexToInsert, section: 0))
            }
            
            self.produces.append(contentsOf: broughtProduces)
            
            self.collectionView.insertItems(at: newIndexPaths)
            
            }, completion: { terminated in
              if terminated {
                if self.produces.count > 0 {
                  if lastProduceId != self.produces[self.produces.count - 1].id {
                    self.collectionView.scrollToItem(at: IndexPath(item: self.produces.count - 1, section: 0), at: .bottom, animated: true)
                  }
                }
              }
          })
          })
      }
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    checkHasScrolledToBottom()
  }
}































