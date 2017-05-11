//
//  TradeStatusVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/4/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import Ax
import SVProgressHUD

class TradeStatusVC: UIViewController {
  
  @IBOutlet weak var editButtonShadowView: UIView!
  var originalOwnerProducesCount = 0
  var originalAnotherProducesCount = 0
  
  var anotherUsername: String?
  var anotherUserId: String?
  var dealId: String?
  
  var dealState: DealState?
  var originalOwnerUserId: String?
  
  var ownerUserName = ""
  var currentDeal: Deal?
  
  var originalTransactionMethod: String?
  var transactionMethod: String?
  
  @IBOutlet weak var statusLabel: UILabel! {
    didSet {
      statusLabel.text = ""
    }
  }
  
  @IBOutlet weak var detailsLabel: UILabel! {
    didSet {
      detailsLabel.text = ""
    }
  }
  
  @IBOutlet weak var transactionMethodLabel: UILabel! {
    didSet {
      transactionMethodLabel.text = ""
    }
  }
  
  @IBOutlet weak var locationTitleLabel: UILabel! {
    didSet {
      locationTitleLabel.text = ""
    }
  }
  
  @IBOutlet weak var locationDetailLabel: UILabel! {
    didSet {
      locationDetailLabel.text = ""
    }
  }
  
  @IBOutlet weak var editTransactionButton: UIButton!
  
  func didConfirmOffer(_ howFinalized: String) {
    transactionMethod = howFinalized
    DispatchQueue.main.async {
      self.transactionMethodLabel.text = "\(self.ownerUserName) says: \(howFinalized)"
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.TradeStatusToFinalizeTrade {
      let vc = segue.destination as? FinalizeTradeVC
      vc?.didConfirmOffer = didConfirmOffer
    }
  }
  
  @IBAction func editTransactionButtonTouched() {
    performSegue(withIdentifier: Storyboard.TradeStatusToFinalizeTrade, sender: nil)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    editButtonShadowView.layoutIfNeeded()
    editButtonShadowView.makeMeBordered()
    
    editButtonShadowView.layer.shadowColor = UIColor.lightGray.cgColor
    editButtonShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    editButtonShadowView.layer.shadowRadius = 3
    editButtonShadowView.layer.shadowOpacity = 0.5
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    var username = ""
    
    SVProgressHUD.show()
    
    Ax.parallel(tasks: [
      
      { [weak self] done in
        if let dealId = self?.dealId {
          Deal.getDeal(byId: dealId, completion: { (result) in
            switch result {
            case .success(let deal):
              self?.currentDeal = deal
              self?.originalTransactionMethod = deal.transactionMethod
              self?.transactionMethod = deal.transactionMethod
              
              DispatchQueue.main.async {
                self?.hasAnyChangeTransactionMethod(
                  deal: deal,
                  transactionMethodLabel: self?.transactionMethodLabel
                )
              }
            case .fail(let error):
              print(error)
            }
            done(nil)
          })
        } else {
          done(nil)
        }
      },
      
      { [weak self] done in
        if let originalOwnerUserId = self?.originalOwnerUserId {
          User.getUser(byUserId: originalOwnerUserId) { [weak self] (result) in
            switch result {
            case .success(let user):
              var currentItemsCount = 0
              var anotherItemsCount = 0
              
              self?.ownerUserName = user.name
              
              if
                let currentUserId = User.currentUser?.uid,
                let originalOwnerUserId = self?.originalOwnerUserId,
                let anotherUserId = self?.anotherUserId
              {
                if currentUserId == originalOwnerUserId {
                  currentItemsCount = self?.originalOwnerProducesCount ?? 0
                  anotherItemsCount = self?.originalAnotherProducesCount  ?? 0
                  
                  username = self?.anotherUsername ?? ""
                } else {
                  currentItemsCount = self?.originalAnotherProducesCount ?? 0
                  anotherItemsCount = self?.originalOwnerProducesCount  ?? 0
                  
                  username = user.name
                }
                
                DispatchQueue.main.async { [weak self] in
                  
                  self?.hasAnyChangeProduceCount(
                    deal: self?.currentDeal,
                    detailsLabel : self?.detailsLabel,
                    currentItemsCount: currentItemsCount,
                    anotherItemsCount: anotherItemsCount,
                    username: username,
                    currentUserId: currentUserId,
                    originalOwnerUserId: originalOwnerUserId,
                    anotherUserId: anotherUserId
                  )
                  
                  self?.locationTitleLabel.text = "\(user.name)'s Garden Location"
                  self?.locationDetailLabel.text = user.location ?? "\(user.name) didn't set his location."
                }
              }
            case .fail(let error):
              print(error)
              break
            }
            
            done(nil)
          }
        } else {
          done(nil)
        }
      }
    ]) { [weak self] (error) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      
      if let currentDeal = self?.currentDeal {
        DispatchQueue.main.async {
          self?.transactionMethodLabel.text = "\(self?.ownerUserName ?? "") says: \(currentDeal.transactionMethod ?? "")"
        }
      }
    }
  }
  
  func hasAnyChangeTransactionMethod(deal: Deal, transactionMethodLabel: UILabel?) {
    if let changes = deal.changes {
      let keys = Array(changes.keys).sorted()
      
      if keys.count > 0 {
        let change = changes[keys.last!] as? [String: Any]
        
        if let _ = change?["transactionMethod"] as? String {
          transactionMethodLabel?.textColor = UIColor.blue
        }
      }
    }
  }
  
  func hasAnyChangeProduceCount(
    deal: Deal?,
    detailsLabel: UILabel?,
    currentItemsCount: Int,
    anotherItemsCount: Int,
    username: String,
    currentUserId: String,
    originalOwnerUserId: String,
    anotherUserId: String
  ) {
    let boldFontAttribute = [
      NSFontAttributeName: UIFont(name: "Montserrat-SemiBold", size: 18)!
    ]
    
    let regularFontAttribuge = [
      NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 18)!
    ]
    
    let blueFontAttribute = [
      NSFontAttributeName: UIFont(name: "Montserrat-SemiBold", size: 18)!,
      NSForegroundColorAttributeName: UIColor.blue
    ]
    
    var currentFontAttributeToUse: [String: Any] = boldFontAttribute
    var anotherFontAttributeToUse: [String: Any] = boldFontAttribute
    
    if let changes = deal?.changes {
      let keys = Array(changes.keys).sorted()
      
      if keys.count > 0 {
        let change = changes[keys.last!] as? [String: Any]
        
        print(currentUserId)
        print(anotherUserId)
        
        print(change)
        print(change?[currentUserId] as? Int)
        print(change?[anotherUserId] as? Int)
        
        if let _ = change?[currentUserId] as? Int {
          currentFontAttributeToUse = blueFontAttribute
        }
        
        if let _ = change?[anotherUserId] as? Int {
          anotherFontAttributeToUse = blueFontAttribute
        }
      }
    }
    
    let text1 = NSAttributedString(string: "You are trading ", attributes: regularFontAttribuge)
    let text2 = NSAttributedString(string: "\(currentItemsCount) item(s) ", attributes: currentFontAttributeToUse)
    let text3 = NSAttributedString(string: "for ", attributes: regularFontAttribuge)
    let text4 = NSAttributedString(string: "\(anotherItemsCount) item(s) ", attributes: anotherFontAttributeToUse)
    let text5 = NSAttributedString(string: "of \(username)'s garden.", attributes: regularFontAttribuge)
    
    let fullString = NSMutableAttributedString()
    fullString.append(text1)
    fullString.append(text2)
    fullString.append(text3)
    fullString.append(text4)
    fullString.append(text5)
    
    detailsLabel?.attributedText = fullString
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    detailsLabel.text = ""
    
    if let dealState = dealState {
      switch dealState {
      case .tradeCancelled:
        fallthrough
      case .tradeCompleted:
        fallthrough
      case .tradeInProcess:
        fallthrough
      case .waitingAnswer:
        statusLabel.text = dealState.rawValue
        editTransactionButton.isHidden = true
      case .tradeRequest:
        statusLabel.text = dealState.rawValue
        editTransactionButton.isHidden = false
      }
    }
  }
}










































