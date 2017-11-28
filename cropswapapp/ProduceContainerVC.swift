//
//  ProduceContainerVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProduceContainerVC: UIViewController {
  var produceChildVC: ProduceChildVC?
  var produce: Produce?
  var isReadOnly = false
  var transactionMethod: String?
  var dealPending: [String: Any]?
  
  var userImageView: UIImageView!
  
  @IBOutlet weak var produceChildBottomConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var makeDealView: UIView!
  @IBOutlet weak var makeDealButton: UIButton! {
    didSet {
      makeDealButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  
  var showProfileFromChild: (() -> Void)? = { }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    User.getUser(byUserId: produce?.ownerId) { [weak self] (result) in
      switch result {
      case .success(let user):
        if let url = URL(string: user.profilePictureURL ?? "") {
          DispatchQueue.main.async {
            self?.userImageView.sd_setImage(with: url)
          }
        }
      case .fail(let error):
        break
      }
    }
  }
  
  func userImageViewTapped() {
    showProfileFromChild?()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    makeDealButton.setTitle("LOADING..", for: .normal)
    makeDealButton.isEnabled = false
    makeDealButton.alpha = 0.5
    
//    User.hasPendingDeal(
//      userIdOne: User.currentUser?.uid,
//      userIdTwo: produce?.ownerId) { (result) in
//        switch result {
//        case .success(let deal):
//          DispatchQueue.main.async { [weak self] in
//            guard let this = self else { return }
//            
//            self?.dealPending = deal
//            
//            this.makeDealButton.alpha = 1
//            this.makeDealButton.isEnabled = true
//            
//            if deal != nil {
//              this.makeDealButton.setTitle("VIEW DEAL", for: .normal)
//            } else {
//              this.makeDealButton.setTitle("MAKE A DEAL", for: .normal)
//            }
//          }
//        case .fail(let error):
//          DispatchQueue.main.async { [weak self] in
//            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            
//            self?.present(alert, animated: true)
//          }
//        }
//    }
    
    if isReadOnly {
      makeDealView.isHidden = true
      produceChildBottomConstraint.constant = -68
    }
    
    navigationController?.navigationBar.isTranslucent = false
    
    edgesForExtendedLayout = []
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    let userImageViewFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
    userImageView = UIImageView(frame: userImageViewFrame)
    userImageView.backgroundColor = .lightGray
    userImageView.layer.cornerRadius = 40 / 2
    userImageView.layer.borderWidth = 1
    userImageView.layer.borderColor = UIColor.clear.cgColor
    userImageView.layer.masksToBounds = true
    userImageView.contentMode = .scaleAspectFit
    
    let userImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(userImageViewTapped))
    userImageViewTapGesture.numberOfTapsRequired = 1
    userImageViewTapGesture.numberOfTouchesRequired = 1
    userImageView.addGestureRecognizer(userImageViewTapGesture)
    userImageView.isUserInteractionEnabled = true
    
    let userImageViewBar = UIBarButtonItem(customView: userImageView)
    navigationItem.rightBarButtonItem = userImageViewBar
    
    
//    let rightButtonIcon = setNavIcon(imageName: "delete-button-icon", size: CGSize(width: 42, height: 52), position: .right)
//    rightButtonIcon.addTarget(self, action: #selector(deleteButtonTouched), for: .touchUpInside)
    
    if let produce = produce {
      let title = "\(produce.name)"
      setNavHeaderTitle(title: title, color: UIColor.black)
    }
  }
  
  func enableMakeDealButton() {
    makeDealButton.isEnabled = true
    makeDealButton.alpha = 1
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    makeDealView.layer.shadowOffset = CGSize(width: 0, height: 0);
    makeDealView.layer.shadowRadius = 2;
    makeDealView.layer.shadowColor = UIColor.black.cgColor
    makeDealView.layer.shadowOpacity = 0.3;
  }
  
  @IBAction func makeDealButtonTouched(_ sender: AnyObject) {
    makeDealButton.isEnabled = false
    makeDealButton.alpha = 0.5
    
    guard let ownerId = produce?.ownerId else {
      return
    }

    guard let ownerName = produce?.ownerUsername else {
      return
    }
    
    guard let currenUserId = User.currentUser?.uid else {
      return
    }
    
    if ownerId != currenUserId {
      SVProgressHUD.show()
      
      Deal.canUserMakeADeal(fromUserId: currenUserId, toUserId: ownerId, completion: { [weak self] (hoursLeft) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
          self?.makeDealButton.isEnabled = true
          self?.makeDealButton.alpha = 1
        }
        
        if hoursLeft > 0 {
          let alert = UIAlertController(title: "Error", message: "You already have a trade in progress with \(ownerName), Please wait \(hoursLeft) seconds before you submit a new request to \(ownerName) or wait for his response!", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          
          self?.present(alert, animated: true)
        } else {
          self?.performSegue(withIdentifier: Storyboard.ProduceContainerToFinalizeTrade, sender: nil)
        }
      })
    } else {
      let alert = UIAlertController(title: "Info", message: "Sorry you can't make a deal with yourself", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      makeDealButton.isEnabled = true
      makeDealButton.alpha = 1
    }
  }
  
  func backButtonTouched() {
    dismiss(animated: true)
//    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissModals"), object: nil)
  }
  
  func didConfirmOffer(_ howFinalized: String) {
    transactionMethod = howFinalized
    performSegue(withIdentifier: Storyboard.ProduceContainerToMakeDeal, sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.ProduceContainerToMakeDeal {
      let vc = segue.destination as? MakeDealVC
      vc?.transactionMethod = transactionMethod
      
      if let produce = produce {
        vc?.anotherOwnerId = produce.ownerId
        vc?.anotherUsername = produce.ownerUsername
        vc?.currentProduceId = produce.id
//        vc?.anotherProduces.append(produce)
      }
      
    } else if segue.identifier == Storyboard.ProduceContainerToFinalizeTrade {
      let vc = segue.destination as? FinalizeTradeVC
      vc?.didConfirmOffer = didConfirmOffer
    } else if segue.identifier == Storyboard.ProduceContainerToTradeDetail {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TradeHomeVC
//      let vc = segue.destination as? TradeHomeVC
      
      vc?.originalOwnerUserId = dealPending?["originalOwnerUserId"] as? String
      vc?.originalOwnerProducesCount = dealPending?["originalOwnerProducesCount"] as? Int ?? 0
      vc?.originalAnotherProducesCount = dealPending?["originalAnotherProducesCount"] as? Int ?? 0
      vc?.dealId = dealPending?["id"] as? String
      vc?.anotherUserId = dealPending?["anotherUserId"] as? String
      vc?.anotherUsername = dealPending?["anotherUsername"] as? String
      vc?.dealState = DealState(rawValue: dealPending?["state"] as? String ?? DealState.tradeRequest.rawValue)
    } else {
      let vc = segue.destination as? ProduceChildVC
      produceChildVC = vc
      vc?.produce = produce
      vc?.enableMakeDealButton = enableMakeDealButton
      vc?.isReadOnly = isReadOnly
      showProfileFromChild = vc?.showProfileFromChild
    }
  }
  
}



















