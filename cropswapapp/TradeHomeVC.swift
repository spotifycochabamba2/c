//
//  TradeHomeVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/20/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class TradeHomeVC: UIViewController {
  var originalOwnerUserId: String?
  
  var originalOwnerProducesCount = 0
  var originalAnotherProducesCount = 0
  
  var listenChatNotificationsHandler: UInt = 0
  
  var dealId: String?
  var anotherUserId: String?
  var anotherUsername: String?
  var dealState: DealState?
  var deselectCurrentRow: () -> Void = {}
  
  @IBOutlet weak var chatButton: UIButton!
  @IBOutlet var chatButtonTopConstraint: NSLayoutConstraint!
  @IBOutlet var chatButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var historialBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var statusBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var itemsBottomConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var processButtonContainerView: UIView!
  @IBOutlet weak var processButton: UIButton!
  @IBOutlet weak var cancelDealButton: UIButton!
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tradeContainerView: UIView!
  @IBOutlet weak var historialContainerView: UIView!
  @IBOutlet weak var statusContainerView: UIView!
  
  var tradeDetailVC: TradeDetailVC?
  var tradeHistorialVC: TradeHistorialVC?
  var tradeStatusVC: TradeStatusVC?
  
  @IBAction func openChatButtonTouched() {
    performSegue(withIdentifier: Storyboard.TradeHomeToTradeChat, sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.TradeHomeToTradeDetail {
      let vc = segue.destination as? TradeDetailVC
      tradeDetailVC = vc
      vc?.dealId = dealId
      vc?.anotherUserId = anotherUserId
      vc?.dealState = dealState
    } else if segue.identifier == Storyboard.TradeHomeToTradeHistorial {
      let vc = segue.destination as? TradeHistorialVC
      vc?.dealId = dealId
      vc?.anotherUserId = anotherUserId
      vc?.didMakeAnotherOffer = didMakeAnotherOffer
      vc?.didAcceptOffer = didAcceptOffer
      vc?.didCancelOffer = didCancelOffer
    } else if segue.identifier == Storyboard.TradeHomeToTradeStatus {
      let vc = segue.destination as? TradeStatusVC
      tradeStatusVC = vc
      vc?.dealState = dealState
      
      vc?.dealId = dealId
      vc?.anotherUserId = anotherUserId
      vc?.originalOwnerUserId = originalOwnerUserId
      vc?.originalOwnerProducesCount = originalOwnerProducesCount
      vc?.originalAnotherProducesCount = originalAnotherProducesCount
      
      vc?.anotherUsername = anotherUsername
    } else if segue.identifier == Storyboard.TradeHistorialToFinalizeTrade {
      let vc = segue.destination as? FinalizeTradeVC
      vc?.didConfirmOffer = didConfirmOffer
    } else if segue.identifier == Storyboard.TradeHomeToTradeChat {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TradeChatVC
      
      vc?.anotherUserId = anotherUserId
      vc?.anotherUsername = anotherUsername
      vc?.dealId = dealId
      
      if let dealId = vc?.dealId,
        let userId = User.currentUser?.uid {
        
        CSNotification.clearChatNotification(
          withDealId: dealId,
          andUserId: userId,
          completion: { (error) in
            print(error)
        })
      }
    }
  }
  
  func didMakeAnotherOffer() {
    segmentedControl.selectedSegmentIndex = 1
    segmentedControl.sendActions(for: .valueChanged)
  }
  
  func didAcceptOffer() {
//    performSegue(withIdentifier: Storyboard.TradeHistorialToFinalizeTrade, sender: nil)
    didConfirmOffer("")
  }
  
  func didCancelOffer() {
    let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to cancel the offer?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (alert) in
      
      guard let ownerId = self?.anotherUserId
        else {
          let alert = UIAlertController(title: "Error", message: "owner user id of the deal not found.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          return
      }
      
      guard let newAnotherId = User.currentUser?.uid else {
        let alert = UIAlertController(title: "Error", message: "another user id of the deal not found.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return
      }
      
      guard let dealId = self?.dealId else {
        let alert = UIAlertController(title: "Error", message: "deal id not found.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return
      }
      
      SVProgressHUD.show()
      Deal.cancelDeal(
        ownerUserId: ownerId,
        anotherUserId: newAnotherId,
        dealId: dealId,
        dateUpdated: Date(),
        completion: { (error) in
          DispatchQueue.main.async {
            SVProgressHUD.dismiss()
          }
          
          if let error = error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            DispatchQueue.main.async {
              self?.present(alert, animated: true)
            }
          } else {
            DispatchQueue.main.async {
              self?.dismiss(animated: true)
            }
          }
      })
    }))
    
    present(alert, animated: true)
  }
  
  func didConfirmOffer(_ howFinalized: String) {
    guard let ownerId = anotherUserId
      else {
        let alert = UIAlertController(title: "Error", message: "owner user id of the deal not found.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return
    }
    
    guard let newAnotherId = User.currentUser?.uid else {
      let alert = UIAlertController(title: "Error", message: "another user id of the deal not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      return
    }
    
    guard let dealId = dealId else {
      let alert = UIAlertController(title: "Error", message: "deal id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      return
    }
    
    SVProgressHUD.show()
    Deal.acceptDeal(
      ownerUserId: ownerId,
      anotherUserId: newAnotherId,
      dealId: dealId,
      dateUpdated: Date()
//      howFinalized: howFinalized
    ) { [weak self] (error) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        if let error = error {
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          DispatchQueue.main.async {
            self?.present(alert, animated: true)
          }
        } else {
          DispatchQueue.main.async {
            self?.dismiss(animated: true)
          }
        }
    }
  }
  
  @IBAction func cancelDealButtonTouched() {
    didCancelOffer()
  }
  
  @IBAction func processButtonTouched() {
    guard let newOwnerId = User.currentUser?.uid
    else {
      return
    }
    
    guard let originalOwnerUserId = originalOwnerUserId
    else {
        return
    }
    
    guard let dealId = dealId else {
      return
    }
    
    guard let newAnotherId = anotherUserId else {
      return
    }
    
    guard let tradeDetailVC = tradeDetailVC else {
      return
    }
    
    let newOwnerProduces = tradeDetailVC.myProduces.filter { return $0.1 > 0 }
    let newAnotherProduces = tradeDetailVC.anotherProduces.filter { return $0.1 > 0 }
    
    print(newOwnerProduces.count)
    print(newAnotherProduces.count)
    
    var transactionMethod = tradeStatusVC?.transactionMethod
    
    if let tMethod = tradeStatusVC?.transactionMethod,
       let originalTransactionMethod = tradeStatusVC?.originalTransactionMethod,
      tMethod == originalTransactionMethod {
      transactionMethod = nil
    }
    
//    var invalidUpdate = false
//    
//    for produce in newOwnerProduces {
//      if produce.1 <= 0 {
//        invalidUpdate = true
//        break
//      }
//    }
//    
//    for produce in newAnotherProduces {
//      if produce.1 <= 0 {
//        invalidUpdate = true
//        break
//      }
//    }
//    
//    print(invalidUpdate)
//    
//    if invalidUpdate {
//      let alert = UIAlertController(title: "Error", message: "Some of the items you want to trade has zero units.", preferredStyle: .alert)
//      alert.addAction(UIAlertAction(title: "OK", style: .default))
//      present(alert, animated: true)
//      return
//    }
    
    print(originalOwnerUserId)
    print(originalOwnerProducesCount)
    print(originalAnotherProducesCount)
    print(newOwnerProduces)
    print(newAnotherProduces)
    
    SVProgressHUD.show()
    Offer.makeAnotherOffer(
      originalOwnerUserId: originalOwnerUserId,
      newOwnerId: newOwnerId,
      newAnotherId: newAnotherId,
      newOwnerProduces: newOwnerProduces.map { return ($0.0.id, $0.1) },
      newAnotherProduces: newAnotherProduces.map { return ($0.0.id, $0.1) },
      dealId: dealId,
      dateCreated: Date(),
      transactionMethod: transactionMethod,
      originalOwnerProducesCount: originalOwnerProducesCount,
      originalAnotherProducesCount: originalAnotherProducesCount
    ) { [weak self] (error) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
        self?.dismiss(animated: true)
      }
    }
  }
  
  func backButtonTouched() {
    deselectCurrentRow()
    dismiss(animated: true)
  }
  
  func configureSegmentedControl(_ control: UISegmentedControl) {
    
    let font = UIFont(name: "Montserrat-Regular", size: 11)
    let fontColorSelected = UIColor.white
    let fontColorNotSelected = UIColor.hexStringToUIColor(hex: "#F83F39")
    
    let selectedAttributes = [
      NSFontAttributeName: font!,
      NSForegroundColorAttributeName: fontColorSelected
    ]
    
    let notSelectedAttributes = [
      NSFontAttributeName: font!,
      NSForegroundColorAttributeName: fontColorNotSelected
    ]
    
    segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    segmentedControl.setTitleTextAttributes(notSelectedAttributes, for: .normal)
    
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let userId = User.currentUser?.uid,
       let dealId = dealId
    {
      listenChatNotificationsHandler = CSNotification.listenChatNotifications(
        byUserId: userId,
        andDealId: dealId,
        completion: { [weak self] (notification) in
          DispatchQueue.main.async {
            if notification.chat > 0 {
              self?.chatButton.backgroundColor = .red
            } else {
              self?.chatButton.backgroundColor = .white
            }
          }
      })
    }

    
    statusContainerView.isHidden = true
    chatButtonTopConstraint.isActive = true
    
    configureSegmentedControl(segmentedControl)
        
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    setNavHeaderTitle(title: "Trade with \(anotherUsername ?? "")", color: UIColor.black)
    
    if let dealState = dealState {
      switch dealState {
      case .tradeCancelled:
        fallthrough
      case .tradeCompleted:
        fallthrough
      case .tradeInProcess:
        fallthrough
      case .waitingAnswer:
        historialBottomConstraint.constant = -60
        statusBottomConstraint.constant = -60
        itemsBottomConstraint.constant = -60
//        segmentedControl.setEnabled(false, forSegmentAt: 1)
        break
      case .tradeRequest:
//        segmentedControl.setEnabled(true, forSegmentAt: 1)
        break
      }
    }
    
    segmentedControl.selectedSegmentIndex = 2
    segmentedControl.sendActions(for: .valueChanged)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    processButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    
    cancelDealButton.layer.borderWidth = 1
    cancelDealButton.layer.cornerRadius = 5.0
    
    cancelDealButton.layer.shadowColor = UIColor.black.cgColor
    cancelDealButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    cancelDealButton.layer.shadowRadius = 7
    cancelDealButton.layer.shadowOpacity = 0.2
    cancelDealButton.layer.borderColor = UIColor.clear.cgColor
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  deinit {
    if let userId = User.currentUser?.uid,
      let dealId = dealId {
      CSNotification.removeListenChatNotifications(
        byUserId: userId,
        andDealId: dealId,
        handlerId: listenChatNotificationsHandler)
    }
  }
  
  
  @IBAction func segmetedControlTouched(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      statusContainerView.isHidden = false
      tradeContainerView.isHidden = true
      historialContainerView.isHidden = true
      
      statusBottomConstraint.constant = 8
      historialBottomConstraint.constant = 8
      itemsBottomConstraint.constant = 8
      
      if let dealState = dealState {
        switch dealState {
        case .tradeCancelled:
          fallthrough
        case .tradeCompleted:
          fallthrough
        case .tradeInProcess:
          fallthrough
        case .waitingAnswer:
          historialBottomConstraint.constant = -60
          statusBottomConstraint.constant = -60
          itemsBottomConstraint.constant = -60
          
          processButtonContainerView.isHidden = true
          break
        case .tradeRequest:
          historialBottomConstraint.constant = 8
          statusBottomConstraint.constant = 8
          itemsBottomConstraint.constant = 8
          
          processButtonContainerView.isHidden = false
          break
        }
      }

//      chatButtonBottomConstraint.isActive = false
//      chatButtonTopConstraint.isActive = true
      view.layoutIfNeeded()
    } else if sender.selectedSegmentIndex == 1 {
      tradeContainerView.isHidden = false
      statusContainerView.isHidden = true
      historialContainerView.isHidden = true
      
      if let dealState = dealState {
        switch dealState {
        case .tradeCancelled:
          fallthrough
        case .tradeCompleted:
          fallthrough
        case .tradeInProcess:
          fallthrough
        case .waitingAnswer:
          
          historialBottomConstraint.constant = -60
          statusBottomConstraint.constant = -60
          itemsBottomConstraint.constant = -60
          
          processButtonContainerView.isHidden = true
          break
        case .tradeRequest:
          historialBottomConstraint.constant = 8
          statusBottomConstraint.constant = 8
          itemsBottomConstraint.constant = 8
          
          processButtonContainerView.isHidden = false
          break
        }
      }
      
//      chatButtonBottomConstraint.isActive = true
//      chatButtonTopConstraint.isActive = false
      
      processButton.setTitle("UPDATE DEAL", for: .normal)
//      processButtonContainerView.isHidden = false
      
      view.layoutIfNeeded()
    } else if sender.selectedSegmentIndex == 2 {
      historialContainerView.isHidden = false
      tradeContainerView.isHidden = true
      statusContainerView.isHidden = true
      historialBottomConstraint.constant = -60
      statusBottomConstraint.constant = -60
      itemsBottomConstraint.constant = -60
      
      chatButtonBottomConstraint.isActive = true
      chatButtonTopConstraint.isActive = false
      
      processButtonContainerView.isHidden = true
      view.layoutIfNeeded()
    }
  }
}


































