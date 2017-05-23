//
//  ProduceContainerVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ProduceContainerVC: UIViewController {
  var produceChildVC: ProduceChildVC?
  var produce: Produce?
  var isReadOnly = false
  var transactionMethod: String?
  
  @IBOutlet weak var produceChildBottomConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var makeDealView: UIView!
  @IBOutlet weak var makeDealButton: UIButton! {
    didSet {
      makeDealButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    makeDealButton.isEnabled = false
    makeDealButton.alpha = 0.5
    
    if isReadOnly {
      makeDealView.isHidden = true
      produceChildBottomConstraint.constant = -68
    }
    
    navigationController?.navigationBar.isTranslucent = false
    
    edgesForExtendedLayout = []
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
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
      Deal.canUserMakeADeal(fromUserId: currenUserId, toUserId: ownerId, completion: { [weak self] (hoursLeft) in
        self?.enableMakeDealButton()
        print(hoursLeft)
        
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
      enableMakeDealButton()
    }
  }
  
  func backButtonTouched() {
    dismiss(animated: true)
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
    } else {
      let vc = segue.destination as? ProduceChildVC
      produceChildVC = vc
      vc?.produce = produce
      vc?.enableMakeDealButton = enableMakeDealButton
    }
  }
  
}



















