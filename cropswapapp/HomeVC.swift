//
//  HomeVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/20/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class HomeVC: UIViewController {
  
  // used for getting paginated data
  var isGettingPaginatedDataFromServer = false
  
  // used for getting data for the first time
  var isGettingFirstDataFromServer = true
  
  let homeCellId = "HomeCellId"
  
  var getNewProducesHandlerId: UInt = 0
  var getRemovedProducesHandlerId: UInt = 0
  var getUpdatedProducesHandlerId: UInt = 0
  
  var time = Date()
  
  var limitProducesBrought: UInt = 4
  
  var ignoreItems = true
  
  var produces = [Produce]()
  
  var producesWanted = [ProduceWanted]()
  
  var currentUser: User?
//  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var popupButton: UIButton!
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var popupBottomLayoutConstraint: NSLayoutConstraint!
  @IBOutlet weak var blurView: UIView!
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  deinit {
    User.stopListeningToGetProducesByListeningAddedNewOnes(handlerId: getNewProducesHandlerId, fromTime: time)
    User.stopListeningToGetProducesByListeningRemovedOnes(handlerId: getRemovedProducesHandlerId)
  }
  
  var showPop: Bool = false {
    didSet {
      var blurViewTransform = CGAffineTransform.identity
      
      if showPop {
        popupButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        popupBottomLayoutConstraint.constant = 0
        
        blurView.isHidden = false
        blurViewTransform = CGAffineTransform.identity
      } else {
        popupButton.transform = CGAffineTransform.identity
        popupBottomLayoutConstraint.constant = popupView.frame.height * -1
        blurViewTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        blurView.isHidden = true
      }
      
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        usingSpringWithDamping: 0.5,
        initialSpringVelocity: 0.5,
        options: [],
        animations: { [weak self] in
          self?.blurView.transform = blurViewTransform
          self?.view.layoutIfNeeded()
        })
    }
  }
  
  

}


// Actions
extension HomeVC {
  @IBAction func myGardenButtonTouched(_ sender: AnyObject) {
    performSegue(withIdentifier: Storyboard.HomeToMyGarden, sender: nil)
  }
  
  @IBAction func cropswapButtonTouched() {
  }
  
  @IBAction func myListButtonTouched() {
  }
  
  @IBAction func addLocationButtonTouched() {
  }
  
  @IBAction func tradesButtonTouched() {
  }
  
  @IBAction func messagesButtonTouched() {
  }
}

import Firebase

extension HomeVC {
  override func viewDidLoad() {
    super.viewDidLoad()
//    customSegmentedControl()
    
    setupCollectionView()
    configureBlurView()

    setNavBarButtons()
    navigationBarIsHidden = false
    
    SVProgressHUD.show()
    getProduces {
      SVProgressHUD.dismiss()
    }
    
    time = Date()
    getNewProducesHandlerId = User.getProducesByListeningAddedNewOnes(fromTime: time) { [unowned self] (newProduce) in

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
  }
  
  func filterBy(producesWanted: [ProduceWanted], producesToFilter: [Produce]) -> [Produce] {
    var filteredProduces = [Produce]()
    
    filteredProduces = producesToFilter.filter { (produceToFilter) -> Bool in
      return producesToFilter.contains(where: { (produce) -> Bool in
        return produceToFilter.id == produce.id
      })
    }
    
    return filteredProduces
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if showPop {
      showPop = false
    }

  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    SVProgressHUD.dismiss()
  }
}





extension HomeVC {
  @IBAction func popupButtonTouched() {
    showPop = !showPop
  }
}







extension HomeVC {
  
  func getProduces(completion: (() -> Void)? = nil) {
    
    User.getProducesOnce(byLimit: limitProducesBrought) { [unowned self] (produces) in
      self.ignoreItems = false
      let producesWanted = self.producesWanted
      self.produces = self.filterBy(producesWanted: producesWanted, producesToFilter: produces)
      self.isGettingFirstDataFromServer = false
      
      DispatchQueue.main.async {
        UIView.transition(
          with: self.collectionView,
          duration: 0.35,
          options: .transitionCrossDissolve,
          animations: {
            self.collectionView.reloadData()
          },
          completion: nil
        )
      }
      
      completion?()
    }
    
//    weak var this = self
//    
//    Ax.serial(tasks: [
//      
//      { done in
//        guard let userId = User.currentUser?.uid else {
//          done(nil)
//          return
//        }
//        
//        ProduceWanted.getProducesWanted(ByUserId: userId, completion: { (producesWanted) in
//          this?.producesWanted = producesWanted
//          
//          done(nil)
//        })
//      },
//      
//      { done in
//        User.getProducesOnce(byLimit: this?.limitProducesBrought ?? 0) { [unowned self] (produces) in
//          self.ignoreItems = false
//          let producesWanted = this?.producesWanted ?? []
//          self.produces = this?.filterBy(producesWanted: producesWanted, producesToFilter: produces) ?? []
//          self.isGettingFirstDataFromServer = false
//          
//          DispatchQueue.main.async {
//            UIView.transition(
//              with: self.collectionView,
//              duration: 0.35,
//              options: .transitionCrossDissolve,
//              animations: {
//                self.collectionView.reloadData()
//              },
//              completion: nil
//            )
//          }
//          
//          done(nil)
//        }
//      }
//      
//    ]) { (error) in
//      completion?()
//    }
  }
  
  func blurViewTapped() {
    showPop = false
  }
  
  func configureBlurView() {
    let blurViewTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(blurViewTapped))
    blurViewTapGestureRecog.numberOfTapsRequired = 1
    blurViewTapGestureRecog.numberOfTouchesRequired = 1
    blurView.isUserInteractionEnabled = true
    blurView.addGestureRecognizer(blurViewTapGestureRecog)
    
    let blurViewSwipeGestureRecog = UISwipeGestureRecognizer(target: self, action: #selector(blurViewTapped))
    blurViewSwipeGestureRecog.direction = .down
    blurView.addGestureRecognizer(blurViewSwipeGestureRecog)
    
    blurView.isHidden = true
    blurView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    
    let blurEffect = UIBlurEffect(style: .light)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    blurEffectView.frame = blurView.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    blurView.addSubview(blurEffectView)
  }
  
  func customSegmentedControl() {
    
//    let font = UIFont(name: "OpenSans-Light", size: 15)
//    let fontColorSelected = UIColor.white
//    let fontColorNotSelected = UIColor.cropswapRed
//    
//    let selectedAttributes = [
//      NSFontAttributeName: font!,
//      NSForegroundColorAttributeName: fontColorSelected
//    ]
//    
//    let notSelectedAttributes = [
//      NSFontAttributeName: font!,
//      NSForegroundColorAttributeName: fontColorNotSelected
//    ]
    
//    segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
//    segmentedControl.setTitleTextAttributes(notSelectedAttributes, for: .normal)

  }
  
  func setNavBarButtons() {
    let leftButtonIcon = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    
    let rightButtonIcon = setNavIcon(imageName: "home-nav-right-icon", size: CGSize(width: 27, height: 7), position: .right)
    rightButtonIcon.addTarget(self, action: #selector(rightButtonIconTouched), for: .touchUpInside)
    
    setNavBarColor(color: .cropswapYellow)
    setNavHeaderIcon(imageName: "home-nav-header-icon", size: CGSize(width: 186, height: 31))
  }
  
  func rightButtonIconTouched() {
    performSegue(withIdentifier: Storyboard.HomeToProducesWanted, sender: nil)
    
//    User.logout()
//    
//    _ = navigationController?.popToRootViewController(animated: true)
  }
  
  func setupCollectionView() {
    let layout = CHTCollectionViewWaterfallLayout()
    
    layout.minimumColumnSpacing = 1.0
    layout.minimumInteritemSpacing = 1.0
    
    collectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
    collectionView.alwaysBounceVertical = true
    
    
    self.collectionView.collectionViewLayout = layout
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.HomeToProduceDetail {
      let vc = segue.destination as? ProduceDetailVC

      let produce = sender as? Produce
      let produceId = produce?.id
      let ownerId = produce?.ownerId

      vc?.produceId = produceId
      vc?.ownerId = ownerId
    }
  }
}







extension HomeVC {
  
  func checkHasScrolledToBottom() {
    let bottomEdge = collectionView.contentOffset.y + collectionView.frame.size.height
    
    if bottomEdge >= collectionView.contentSize.height {
      if produces.count > 0 && !isGettingPaginatedDataFromServer && !isGettingFirstDataFromServer {
        let lastProduceId = produces[produces.count - 1].id
        isGettingPaginatedDataFromServer = true
        SVProgressHUD.show()
        User.getProducesOnce(byLimit: limitProducesBrought, startingFrom: lastProduceId, completion: { [unowned self] (broughtProduces) in
          SVProgressHUD.dismiss()
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








extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return produces.count == 0 ? 0 : 1
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 200) // 130
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return produces.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let produce = produces[indexPath.row]
    
    performSegue(withIdentifier: Storyboard.HomeToProduceDetail, sender: produce)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeCellId, for: indexPath) as! HomeCell
    let produce = produces[indexPath.row]
    
    cell.produceName = produce.produceType
    cell.producePictureURL = produce.firstPictureURL ?? ""
    cell.price = produce.price
    cell.username = produce.ownerUsername
    cell.distance = 0
    
    return cell
  }
  
}















































