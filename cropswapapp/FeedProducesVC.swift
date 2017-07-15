//
//  MyFeedVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class FeedProducesVC: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  
//  var searchResultFeedVC: SearchResultFeedVC!
//  var produceSearchController: UISearchController!
  
  var userCoordinates = [String: Any]()
  
  let cellIdentifier = "FeedCellId"
  var currentUser: User?
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
  
  var didSelectProduce: (Produce) -> Void = { _ in }
  
  var isFilterEnabled = false
  var userIdsAroundMe = [String]()
  
  deinit {
    User.stopListeningToGetProducesByListeningAddedNewOnes(handlerId: getNewProducesHandlerId, fromTime: time)
    User.stopListeningToGetProducesByListeningRemovedOnes(handlerId: getRemovedProducesHandlerId)
    
//    NotificationCenter.default.removeObserver(
//      self,
//      name: NSNotification.Name(rawValue: "dismissModals"),
//      object: nil
//    )
  }
  
  func didSelectDistance(_ distance: Int) {
    isFilterEnabled = distance > 0
    
    if !isFilterEnabled {
      User.getProducesOnce(byLimit: limitProducesBrought) { [weak self] (produces) in
        print(produces.count)
        SVProgressHUD.dismiss()
        
        self?.dataGotFromServer = true
        
        self?.ignoreItems = false
        
        self?.produces = produces.filter({ (produce) -> Bool in
          return produce.liveState ?? "" != ProduceState.archived.rawValue
        })
        
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
    } else {
      SVProgressHUD.show()
      Ax.serial(tasks: [
        
        { [weak self] done in
          User.getUser(byUserId: User.currentUser?.uid, completion: { (result) in
            switch result {
            case .success(let user):
              self?.currentUser = user
              break
            case .fail(let error):
              print(error)
              break
            }
            
            done(nil)
          })
        },
        
        { [weak self] done in
          
          if let user = self?.currentUser,
             let lat = user.latitude,
             let lng = user.longitude
          {
            User.getProducesBy(
              latitude: lat,
              longitude: lng,
              radius: distance,
              completion: { (produces, userIds) in
                self?.produces = produces.filter({ (produce) -> Bool in
                  return produce.liveState != ProduceState.archived.rawValue
                })

                self?.userIdsAroundMe = userIds
                
                done(nil)
            })
          } else {
            done(nil)
          }
        }
      ], result: { [weak self] (error) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
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
        
        print(error)
      })

    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.FeedToProduce {
      
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProduceContainerVC
      
      vc?.produce = sender as? Produce
      
//      NotificationCenter.default.addObserver(
//        self,
//        selector: #selector(dismissModals(notification:)),
//        name: NSNotification.Name(rawValue: "dismissModals"),
//        object: nil
//      )
    }
  }
  
//  func dismissModals(notification: Notification) {
//    self.dismiss(animated: true)
//    NotificationCenter.default.removeObserver(
//      self,
//      name: NSNotification.Name(rawValue: "dismissModals"),
//      object: nil
//    )
//  }
  
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
    
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }
    Ax.serial(tasks: [
    
      { done in
        User.getUser(byUserId: User.currentUser?.uid, completion: { [weak self] (result) in
          guard let this = self else {
            done(nil)
            return
          }
          
          switch result {
          case .success(let user):
            this.currentUser = user
          case .fail(let error):
            print(error)
          }
          
          done(nil)
        })
      },
      
      { [weak self] done in
        guard let this = self else {
          done(nil)
          return
        }
        
        User.getProducesOnce(byLimit: this.limitProducesBrought) { [weak self] (produces) in
          print(produces.count)
          SVProgressHUD.dismiss()
          
          self?.dataGotFromServer = true
          
          self?.ignoreItems = false
          
          self?.produces = produces.filter({ (produce) -> Bool in
            return produce.liveState ?? "" != ProduceState.archived.rawValue
          })
          
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
        
        this.time = Date()
        this.getNewProducesHandlerId = User.getProducesByListeningAddedNewOnes(fromTime: this.time) { [weak self] (newProduce) in
          print(newProduce)
          guard let this = self else { return }
          
          if this.userIdsAroundMe.contains(newProduce.ownerId) {
            this.collectionView.performBatchUpdates({
              
              this.produces.insert(newProduce, at: 0)
              let indexPath = IndexPath(item: 0, section: 0)
              this.collectionView.insertItems(at: [indexPath])
              }, completion: { (finished) in
                
            })
          }
        }
        
        
        
        this.getRemovedProducesHandlerId = User.getProducesByListeningRemovedOnes(completion: { [weak self] (produceIdRemoved) in
          guard let this = self else { return }
          
          let produceIndex = this.produces.index(where: { (produce) -> Bool in
            return produce.id == produceIdRemoved
          })
          
          if let produceIndex = produceIndex {
            this.collectionView.performBatchUpdates({
              this.produces.remove(at: produceIndex)
              let indexPath = IndexPath(item: produceIndex, section: 0)
              this.collectionView.deleteItems(at: [indexPath])
              }, completion: nil)
          }
          })
        
        
        this.getUpdatedProducesHandlerId = User.getProducesByListeningUpdatedOnes(completion: { [weak self] (produceUpdated) in
          
          guard let this = self else { return }
          
          let produceIndex = this.produces.index(where: { (produce) -> Bool in
            return produce.id == produceUpdated.id
          })
          
          if let produceIndex = produceIndex {
            
            if produceUpdated.liveState ?? "" == ProduceState.archived.rawValue {
              this.collectionView.performBatchUpdates({
                this.produces.remove(at: produceIndex)
                let indexPath = IndexPath(item: produceIndex, section: 0)
                this.collectionView.deleteItems(at: [indexPath])
                }, completion: nil)
            } else {
              this.collectionView.performBatchUpdates({
                this.produces[produceIndex] = produceUpdated
                let indexPath = IndexPath(item: produceIndex, section: 0)
                this.collectionView.reloadItems(at: [indexPath])
                }, completion: nil)
            }
          }
          })
        
        done(nil)
      }
    
    ]) { (error) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
    }
    
    collectionView.alwaysBounceVertical = true
  }
  
}

extension FeedProducesVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FeedCell

    let produce = produces[indexPath.row]
    
    cell.producePictureURL = produce.firstPictureURL ?? ""
    cell.produceName = produce.name
    cell.price = produce.price
    
    if produce.distance == nil {
      let ownerId = produce.ownerId
      
      if let currentUser = currentUser,
         let currentUserLatitude = currentUser.latitude,
         let currentUserLongitude = currentUser.longitude
      {
        User.getUser(byUserId: ownerId, completion: { [weak self] (result) in
          switch result {
          case .success(let user):
            if let anotherUserLatitude = user.latitude,
               let anotherUserLongitude = user.longitude
            {
              
              let distance = Utils.getDistanceInKM(
                              fromLatitude: currentUserLatitude,
                              fromLongitude: currentUserLongitude,
                              toLatitude: anotherUserLatitude,
                              toLongitude: anotherUserLongitude
                            )
              
              self?.produces[indexPath.row].distance = distance
              DispatchQueue.main.async {
                cell.distance = distance
              }
            } else {
              DispatchQueue.main.async {
                self?.produces[indexPath.row].distance = 0
                cell.distance = 0
              }
            }
          case .fail(let error):
            DispatchQueue.main.async {
              self?.produces[indexPath.row].distance = 0
              cell.distance = 0
            }
            print(error)
          }
        })
      } else {
        produces[indexPath.row].distance = 0
        cell.distance = 0
      }
    } else {
      cell.distance = produce.distance!
    }
    
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
    didSelectProduce(produce)
//    performSegue(withIdentifier: Storyboard.FeedToProduce, sender: produce)
  }
}


extension FeedProducesVC {
  
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
          
          var broughtProduces = broughtProduces
          
          broughtProduces = broughtProduces.filter({ (produce) -> Bool in
            return produce.liveState ?? "" != ProduceState.archived.rawValue
          })
          
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
              }
          })
          })
      }
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    if !isFilterEnabled {
      checkHasScrolledToBottom()
    }
  }
}





























