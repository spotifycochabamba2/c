//
//  GardenVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class GardenVC: UIViewController {
  
  var currentUserId: String?
  var isCurrentOwner = true
  
  @IBOutlet weak var addProduceButton: UIButton!
  @IBOutlet weak var collectionView: UICollectionView!
  let cellIdentifier = "FeedCellId"
  var produces = Array<[String: Any]>()
  
  var time = Date()
  var addedOnesHandlerId: UInt = 0
  var updatedOnesHandlerId: UInt = 0
  
  var dataGotFromServer = false
  
  deinit {
    if let userId = currentUserId {
      User.stopListeningToGetProducesByUserByListeningAddedOnes(handlerId: addedOnesHandlerId, fromTime: time, fromUserId: userId)
      User.stopListeningToGetProducesByUserByListeningUpdatedOnes(handlerId: updatedOnesHandlerId, fromUserId: userId)
    }
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
    
    if !isCurrentOwner {
      addProduceButton.isHidden = true
    }
    
    if currentUserId == nil {
      currentUserId = User.currentUser?.uid
    }
    
    if let userId = currentUserId {
      
      SVProgressHUD.show()
      User.getProducesByUser(byUserId: userId) { [weak self] produces in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        self?.dataGotFromServer = true
        self?.produces = produces.filter({ (produce) -> Bool in
          let liveState = produce["liveState"] as? String ?? ""
          return liveState != ProduceState.archived.rawValue
        })
        
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
      
      addedOnesHandlerId = User.getProducesByUserByListeningAddedOnes(fromTime: time, fromUserId: userId, completion: { (newProduce) in
        print(newProduce)
        
        self.collectionView.performBatchUpdates({
          
          self.produces.insert(newProduce, at: 0)
          let indexPath = IndexPath(item: 0, section: 0)
          self.collectionView.insertItems(at: [indexPath])
          }, completion: { (finished) in
            
        })
        
      })
      
      updatedOnesHandlerId = User.getProducesByUserByListeningUpdatedOnes(byUserId: userId, completion: { (produceUpdated) in
        
        let produceIndex = self.produces.index(where: { (produce) -> Bool in
          guard
            let produceId = produce["id"] as? String,
            let produceIdUpdated = produceUpdated["id"] as? String else {
              return false
          }
          
          return produceId == produceIdUpdated
        })
        
        if let produceIndex = produceIndex {
          self.collectionView.performBatchUpdates({
            self.produces[produceIndex] = produceUpdated
            let indexPath = IndexPath(item: produceIndex, section: 0)
            self.collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
      })
    }
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    
    _ = setNavIcon(imageName: "search-icon", size: CGSize(width: 17, height: 17), position: .right)
    
    setNavHeaderTitle(title: "My Garden", color: UIColor.black)
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
    
    self.collectionView.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    
    automaticallyAdjustsScrollViewInsets = false
    collectionView.alwaysBounceVertical = true
  }
  
  @IBAction func addItemButtonTouched() {
    performSegue(withIdentifier: Storyboard.GardenToAddProduce, sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.GardenToAddProduce {
      let nc = segue.destination as? UINavigationController
      let vc = nc?.viewControllers.first as? AddProduceContainerVC
      let produce = sender as? [String: Any]
      
      vc?.currentProduceId = produce?["id"] as? String
      vc?.currentProduceState = produce?["liveState"] as? String
    } else if segue.identifier == Storyboard.GardenToProduceContainer {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProduceContainerVC
      vc?.produce = sender as? Produce
    }
  }

}

extension GardenVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FeedCell
    
    let produce = produces[indexPath.row]
    
    cell.producePictureURL = produce["firstPictureURL"] as? String ?? ""
    cell.produceName = produce["produceType"] as? String ?? ""
    cell.price = produce["price"] as? Double ?? 0
    cell.distance = 0
    
    if let state = produce["liveState"] as? String,
      state == ProduceState.archived.rawValue
    {
      cell.contentView.alpha = 0.5
    } else {
      cell.contentView.alpha = 1
    }
//    if
//      let imageURL = produce["firstPictureURL"] as? String,
//      let produceType = produce["produceType"] as? String
//    {
//      cell.producePictureURL = imageURL
//      cell.produceName = produceType
//      cell.price = produce["price"]
////      cell.price = (produce["price"] as? Double) ?? 0
//    }

//    cell.distanceLabel.isHidden = true
    
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
    let produceJson = produces[indexPath.row]
    
    if isCurrentOwner {
      performSegue(withIdentifier: Storyboard.GardenToAddProduce, sender: produceJson)
    } else {
      if let ownerId = produceJson["ownerId"] as? String {
        SVProgressHUD.show()
        User.getUser(byUserId: ownerId, completion: { (result) in
          DispatchQueue.main.async {
            SVProgressHUD.dismiss()
          }
          switch result {
          case .success(let user):
            guard
              let produceId = produceJson["id"] as? String,
              let produceName = produceJson["name"] as? String
            else {
             return
            }
            
            let produce = Produce(
              id: produceId,
              name: produceName,
              ownerId: ownerId,
              ownerUsername: user.name
            )
            
            DispatchQueue.main.async { [weak self] in
              self?.performSegue(
                withIdentifier: Storyboard.GardenToProduceContainer,
                sender: produce
              )
            }
          case .fail(let error):
            print(error)
          }
        })
      }
    }
  }
}



























