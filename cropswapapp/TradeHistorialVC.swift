//
//  TradeHistorialVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/20/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class TradeHistorialVC: UITableViewController {
  
  var dealId: String?
  var offers = [[String: Any]]()
  var anotherUserId: String?
  var anotherUser: User?
  var deal: Deal?
  
  var didMakeAnotherOffer: () -> Void = {}
  var didAcceptOffer: () -> Void = {}
  var didCancelOffer: () -> Void = {}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 300;
  }
  
  func loadData() {
    SVProgressHUD.show()
    
    Ax.parallel(tasks: [
      { [weak self] done in
        if let anotherUserId = self?.anotherUserId {
          User.getUser(byUserId: anotherUserId, completion: { [weak self] (result) in
            switch result {
            case .success(let user):
              self?.anotherUser = user
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
        if let dealId = self?.dealId {
          Offer.getOffers(byDealId: dealId, completion: { [weak self] (offers) in
            self?.offers = offers
            
            done(nil)
            })
        } else {
          done(nil)
        }
      },
      
      { [weak self] done in
        if let dealId = self?.dealId {
          Deal.getDeal(byId: dealId, completion: { (result) in
            switch result {
            case .success(let deal):
              self?.deal = deal
            case .fail(let error):
              print(error)
            }
            
            done(nil)
          })
        } else {
          done(nil)
        }
        
      }
    ]) { [weak self] (error) in
//      SVProgressHUD.popActivity()
      
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
        self?.tableView.reloadData()
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    

  }
}


extension TradeHistorialVC {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return offers.count
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    DispatchQueue.main.async {
//      cell.layoutIfNeeded()
//      cell.layoutSubviews()
      cell.setNeedsDisplay()
//    }
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    DispatchQueue.main.async {
//      cell.layoutIfNeeded()
//      cell.layoutSubviews()
//      cell.setNeedsDisplay()
//    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TradeHistorialCell.cellId, for: indexPath) as! TradeHistorialCell
    cell.clearViews()
    
    let offer = offers[indexPath.row]
    let currenUserId = User.currentUser?.uid ?? ""
    let offerOwnerId = offer["ownerUserId"] as? String ?? ""
    
    if indexPath.row == 0 {
      cell.contentView.alpha = 1.0
    } else {
      cell.contentView.alpha = 0.5
    }
    
    if offerOwnerId != currenUserId {
      if let anotherProduces = offer["ownerProduces"] as? [(Produce, Int)] {
        cell.anotherProduces = anotherProduces
      }
      
      if let myProduces = offer["anotherProduces"] as? [(Produce, Int)] {
        cell.myProduces = myProduces
      }
    } else {
      if let anotherProduces = offer["anotherProduces"] as? [(Produce, Int)] {
        cell.anotherProduces = anotherProduces
      }
      
      if let myProduces = offer["ownerProduces"] as? [(Produce, Int)] {
        cell.myProduces = myProduces
      }
    }
    
//    print(" cielo ---------------------------------")
//    print(" cielo \(anotherProduces)")
//    print(" cielo \(myProduces)")
//    print(" cielo ---------------------------------")
    
    DispatchQueue.main.async {
      cell.dateCreated = offer["dateCreated"] as? Double
    }
    
    if let anotherUser = anotherUser {
      DispatchQueue.main.async {
        cell.anotherUser = anotherUser
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
}





public extension DispatchQueue {
  
  private static var _onceTracker = [String]()
  
  public class func once(token: String, block:(Void)->Void) {
    objc_sync_enter(self); defer { objc_sync_exit(self) }
    
    if _onceTracker.contains(token) {
      return
    }
    
    _onceTracker.append(token)
    block()
  }
}


































