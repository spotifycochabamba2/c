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
  @IBOutlet weak var statusView: UIView!
  
  
  @IBOutlet weak var yourImageView: UIImageViewCircular!
  @IBOutlet weak var anotherImageView: UIImageViewCircular!
  
  @IBOutlet weak var yourNameLabel: UILabel! {
    didSet {
      yourNameLabel.text = "Your garden"
    }
  }
  @IBOutlet weak var anotherNameLabel: UILabel! {
    didSet {
      anotherNameLabel.text = "Name"
    }
  }
  
  @IBOutlet weak var yourDetailLabel: UILabel! {
    didSet {
      yourDetailLabel.text = ""
    }
  }
  @IBOutlet weak var anotherDetailLabel: UILabel! {
    didSet {
      anotherDetailLabel.text = ""
    }
  }
  
  @IBOutlet weak var transactionMethodImageView: UIImageView!
  @IBOutlet weak var transactionMethodLabel: UILabel! {
    didSet {
      transactionMethodLabel.text = ""
    }
  }
  
  @IBOutlet weak var requestLocationButton: UIButton!
  
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
  @IBOutlet weak var locationStackView: UIStackView!
  
  @IBOutlet weak var editButtonShadowView: UIView!
  var originalOwnerProducesCount = 0
  var originalAnotherProducesCount = 0
  
  var anotherUsername: String?
  var anotherUserId: String?
  var dealId: String?
  
  var currentUser: User?
  
  var dealState: DealState?
  var originalOwnerUserId: String?
  
  var ownerUserName = ""
  var currentDeal: Deal?
  
  var originalTransactionMethod: String?
  var transactionMethod: String?
  
  var userUpdatedStateDeal: () -> Void = { }
  
  @IBOutlet weak var statusImageView: UIImageView!
  
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
  
//  @IBOutlet weak var transactionMethodLabel: UILabel! {
//    didSet {
//      transactionMethodLabel.text = ""
//    }
//  }
//  
//  @IBOutlet weak var locationTitleLabel: UILabel! {
//    didSet {
//      locationTitleLabel.text = ""
//    }
//  }
//  
//  @IBOutlet weak var locationDetailLabel: UILabel! {
//    didSet {
//      locationDetailLabel.text = ""
//    }
//  }
  
  @IBOutlet weak var editTransactionButton: UIButton!
  
  func didConfirmOffer(_ howFinalized: String) {
    userUpdatedStateDeal()
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
    
//    editButtonShadowView.layoutIfNeeded()
//    editButtonShadowView.makeMeBordered()
//    
//    editButtonShadowView.layer.shadowColor = UIColor.lightGray.cgColor
//    editButtonShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//    editButtonShadowView.layer.shadowRadius = 3
//    editButtonShadowView.layer.shadowOpacity = 0.5
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
//                self?.hasAnyChangeTransactionMethod(
//                  deal: deal,
//                  transactionMethodLabel: self?.transactionMethodLabel
//                )
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
      
//      { done in
//        
//        if let userId = User.currentUser?.uid {
//          User.getUser(byUserId: userId, completion: { [weak self] (result) in
//            switch result {
//            case .success(let user):
//              self?.currentUser = user
//              
//                          case .fail(let error):
//              print(error)
//            }
//            
//            done(nil)
//          })
//        }
//        
//      },
      
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
                  // owner
                  currentItemsCount = self?.originalOwnerProducesCount ?? 0
                  
                  anotherItemsCount = self?.originalAnotherProducesCount  ?? 0
                  
                  // second
                  username = self?.anotherUsername ?? ""
                  
                  if let url = URL(string: user.profilePictureURL ?? "") {
                    self?.yourImageView.sd_setImage(with: url)
                  }
                  
//                  if let userId = self?.anotherUserId {
                  User.getUser(byUserId: anotherUserId, completion: { [weak self] (result) in
                    switch result {
                    case .success(let user):
                      if let url = URL(string: user.profilePictureURL ?? "") {
                        self?.anotherImageView.sd_setImage(with: url)
                      }
                    case .fail(let error):
                      print(error)
                    }
                    
                    done(nil)
                    })
                  //                  }
                  
                  
                } else {
                  // another
                  currentItemsCount = self?.originalAnotherProducesCount ?? 0
                  anotherItemsCount = self?.originalOwnerProducesCount  ?? 0
                  
                  username = user.name
                  
                  if let url = URL(string: user.profilePictureURL ?? "") {
                    self?.anotherImageView.sd_setImage(with: url)
                  }
                  

                  User.getUser(byUserId: currentUserId, completion: { [weak self] (result) in
                    switch result {
                    case .success(let user):
                      //                        self?.currentUser = user
                      
                      if let url = URL(string: user.profilePictureURL ?? "") {
                        self?.yourImageView.sd_setImage(with: url)
                      }
                    case .fail(let error):
                      print(error)
                    }
                    
                    done(nil)
                    })

                }
                
                

                
                
                
                DispatchQueue.main.async { [weak self] in
                  
                  self?.anotherNameLabel.text = "\(username)'s Garden"
                  
                  if currentItemsCount > 1 {
                    self?.yourDetailLabel.text = "\(currentItemsCount) items"
                  } else {
                    self?.yourDetailLabel.text = "\(currentItemsCount) item"
                  }
                  
                  if anotherItemsCount > 1 {
                    self?.anotherDetailLabel.text = "\(anotherItemsCount) items"
                  } else {
                    self?.anotherDetailLabel.text = "\(anotherItemsCount) item"
                  }
//                  self?.hasAnyChangeProduceCount(
//                    deal: self?.currentDeal,
//                    detailsLabel : self?.detailsLabel,
//                    currentItemsCount: currentItemsCount,
//                    anotherItemsCount: anotherItemsCount,
//                    username: username,
//                    currentUserId: currentUserId,
//                    originalOwnerUserId: originalOwnerUserId,
//                    anotherUserId: anotherUserId
//                  )
                  
                  if let showAddress = user.showAddress,
                    showAddress {
                    let location = "\(user.street ?? "") \(user.city ?? "") \(user.state ?? "") \(user.zipCode ?? "")"
                    self?.locationTitleLabel.text = "\(user.name)'s Location"
                    self?.locationDetailLabel.text = location
                    self?.locationStackView.isHidden = false
                    self?.requestLocationButton.isHidden = true
                  } else {
                    self?.locationStackView.isHidden = true
                    self?.requestLocationButton.isHidden = false
                    self?.requestLocationButton.setTitle("REQUEST \(user.name.uppercased())'S LOCATION", for: .normal)
                  }
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
          if let transactionMethod = currentDeal.transactionMethod {
            if transactionMethod == HowFinalized.illDrive.rawValue {
              self?.transactionMethodImageView.image = UIImage(named: "illdrive-gray-image-no-title")
            } else if transactionMethod == HowFinalized.letsMeetHalfway.rawValue {
              self?.transactionMethodImageView.image = UIImage(named: "letsmeet-gray-image-no-title")
            } else {
              self?.transactionMethodImageView.image = UIImage(named: "youdrive-gray-image-no-title")
            }
          }
          
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
//  @IBOutlet weak var requestLocationButton: UIButton!
//  
//  @IBOutlet weak var locationTitleLabel: UILabel!
//  @IBOutlet weak var locationDetailLabel: UILabel!
//  @IBOutlet weak var locationStackView: UIStackView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationStackView.isHidden = true
    requestLocationButton.isHidden = true
//    detailsLabel.text = ""
    
    if let dealState = dealState {
      switch dealState {
      case .tradeDeleted:
        fallthrough
      case .tradeCancelled:
        statusView.backgroundColor = UIColor.hexStringToUIColor(hex: "#f83f39")
        statusLabel.text = dealState.rawValue
//        transactionMethodImageView.image = UIImage(named: "")
//        editTransactionButton.isHidden = true
      case .tradeCompleted:
        statusView.backgroundColor = UIColor.hexStringToUIColor(hex: "#37d67c")
        statusLabel.text = dealState.rawValue
//        editTransactionButton.isHidden = true
      case .tradeInProcess:
        fallthrough
      case .waitingAnswer:
        statusView.backgroundColor = UIColor.hexStringToUIColor(hex: "#1572fb")
        statusLabel.text = dealState.rawValue
//        editTransactionButton.isHidden = true
      case .tradeRequest:
        statusView.backgroundColor = UIColor.hexStringToUIColor(hex: "#1572fb")
        statusLabel.text = dealState.rawValue
//        editTransactionButton.isHidden = false
      }
    }
  }
}










































