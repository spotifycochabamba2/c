//
//  TradeListVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class TradeListVC: UIViewController {
  
  var getUpdatedDealsHandlerId: UInt = 0
  
  @IBOutlet weak var tradesTableView: UITableView!
  var deals = [[String: Any]]()
  
  var dataGotFromServer = false
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
  }
  
  func deselectCurrentRow() {
    if let selectedRow = tradesTableView.indexPathForSelectedRow {
      tradesTableView.deselectRow(at: selectedRow, animated: true)
    }
  }
  
  deinit {
    if let userId = User.currentUser?.uid {
      Deal.removeListentingDealsUpdated(byUserId: userId, handlerId: getUpdatedDealsHandlerId)
    }
    
//    NotificationCenter.default.removeObserver(
//      self,
//      name: NSNotification.Name(rawValue: "dismissModals"),
//      object: nil
//    )
  }
  
  func requestLocationPushNotificationGot(notification: Notification) {
    if let data = notification.object as? [String: Any] {
      if let deal = data["deal"] as? [String: Any] {
        print(deal)
        //performSegue(withIdentifier: Storyboard.TradeListToTradeDetail, sender: deal)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    NotificationCenter.default.addObserver(
//      self,
//      selector: #selector(requestLocationPushNotificationGot),
//      name: Notification.Name(
//        Constants.PushNotification.chatPushNotificationId
//      ),
//      object: nil)
    
    if let userId = User.currentUser?.uid {
      
//      getUpdatedDealsHandlerId = Deal.getDealsByListeningUpdatedOnes(byUserId: userId, completion: { [weak self] (dealUpdated) in
//        
//        let dealIndex = self?.deals.index(where: { (deal) -> Bool in
//          let currentDealId = deal["id"] as? String ?? ""
//          let dealUpdatedId = dealUpdated["id"] as? String ?? " "
//          
//          return currentDealId == dealUpdatedId
//        })
//        
//        if let dealIndex = dealIndex {
//          let indexPath = IndexPath(row: dealIndex, section: 0)
//          
//          DispatchQueue.main.async {
//            self?.tradesTableView.reloadRows(at: [indexPath], with: .automatic)
//          }
//        }
//      })
      
      
      
      SVProgressHUD.show()
      _ = Deal.getDeals(byUserId: userId, completion: { [weak self] (deals) in
        self?.dataGotFromServer = true
        
        SVProgressHUD.dismiss()
        self?.deals = deals.filter({ (deal) -> Bool in
          let dealState = deal["state"] as? String ?? ""
          
          return dealState != DealState.tradeDeleted.rawValue
        })
        
        DispatchQueue.main.async {
          self?.tradesTableView.reloadData()
        }
      })
    }
    
    
    automaticallyAdjustsScrollViewInsets = false
    
    _ = setNavIcon(imageName: "", size: CGSize(width: 0, height: 0), position: .left)
    
    setNavHeaderTitle(title: "Trade List", color: UIColor.black)
    
    navigationController?.navigationBar.isHidden = false
    navigationController?.isNavigationBarHidden = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    deselectCurrentRow()
    
    if !dataGotFromServer {
      DispatchQueue.main.async {
        SVProgressHUD.show()
      }
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
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.TradeListToTradeDetail {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TradeHomeVC
      let deal = sender as? [String: Any]
      
      vc?.originalOwnerUserId = deal?["originalOwnerUserId"] as? String
      vc?.originalOwnerProducesCount = deal?["originalOwnerProducesCount"] as? Int ?? 0
      vc?.originalAnotherProducesCount = deal?["originalAnotherProducesCount"] as? Int ?? 0
      vc?.dealId = deal?["id"] as? String
      vc?.anotherUserId = deal?["anotherUserId"] as? String
      vc?.anotherUsername = deal?["anotherUsername"] as? String
      vc?.dealState = DealState(rawValue: deal?["state"] as? String ?? DealState.tradeRequest.rawValue)
      vc?.deselectCurrentRow = deselectCurrentRow
      
      if let dealId = deal?["id"] as? String,
        let userId = User.currentUser?.uid
      {
        CSNotification.clearTradeNotification(
          withDealId: dealId,
          andUserId: userId,
          completion: { (error) in
            print(error)
        })
      }
    } else if segue.identifier == Storyboard.TradeListToProfile {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProfileContainerVC
      let values = sender as? [String: Any]
      
      vc?.currentUserId = values?["userId"] as? String
      vc?.currentUsername = values?["username"] as? String
      vc?.showBackButton = true
      
//      NotificationCenter.default.addObserver(
//        self,
//        selector: #selector(dismissModals(notification:)),
//        name: NSNotification.Name(rawValue: "dismissModals"),
//        object: nil
//      )
    }
  }
}


extension TradeListVC: UITableViewDataSource, UITableViewDelegate {
  
  func userImageTapped(userId: String, username: String) {
    var values = [String: Any]()
    values["userId"] = userId
    values["username"] = username
    
    performSegue(withIdentifier: Storyboard.TradeListToProfile, sender: values)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    let deal = deals[indexPath.row]
    let dealState = deal["state"] as? String ?? ""
    
    return dealState != DealState.tradeCompleted.rawValue
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      print("delete at indexPath.row: \(indexPath.row)")
      
      let confirmationAlert = UIAlertController(title: "Confirmation", message: "Are you sure to delete this trade?", preferredStyle: .alert)
      confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] (_) in
//        self?.tradesTableView.beginUpdates()
        DispatchQueue.main.async {
          self?.tradesTableView.setEditing(false, animated: true)
//          self?.tradesTableView.setEditing(true, animated: false)
        }
//        self?.tradesTableView.endUpdates()
      }))
      
      confirmationAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] (_) in
        if indexPath.row >= 0 {
          if let deal = self?.deals[indexPath.row] {
            let ownerUserId = User.currentUser?.uid ?? ""
            let anotherUserId = deal["anotherUserId"] as? String ?? ""
            let dealId = deal["id"] as? String ?? ""
            
            DispatchQueue.main.async {
              SVProgressHUD.show()
            }
            
            Deal.deleteDeal(
              byOwnerUserId: ownerUserId,
              andAnotherUserId: anotherUserId,
              andDealId: dealId,
              completion: { (error) in
                DispatchQueue.main.async {
                  SVProgressHUD.dismiss()
                }
                
                if let errorDesc = error?.localizedDescription {
                  let errorAlert = UIAlertController(title: "Error", message: errorDesc, preferredStyle: .alert)
                  errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                  
                  DispatchQueue.main.async {
                    self?.present(errorAlert, animated: true)
                  }
                } else {
//                  self?.deals.remove(at: indexPath.row)
                }
            })
          }
        }
      }))
      
      present(confirmationAlert, animated: true)
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let deal = deals[indexPath.row]
    performSegue(withIdentifier: Storyboard.TradeListToTradeDetail, sender: deal)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TradeListCell.cellId, for: indexPath) as! TradeListCell
    let deal = deals[indexPath.row]
    
    let dealState = deal["state"] as? String ?? ""
    let dealAnotherUsername = deal["anotherUsername"] as? String ?? ""
    let dealAnotherUserId = deal["anotherUserId"] as? String ?? ""
    let dealNumberProduces = deal["numberProducesTrade"] as? Int ?? 0
//    let dealAnotherUserId = deal["anotherUserId"] as? String ?? ""
    let dealDate = deal["dateCreated"] as? Double ?? 0
    
    let trade = deal["trade"] as? Int ?? 0
    let chat = deal["chat"] as? Int ?? 0
    
    cell.anotherUserId = dealAnotherUserId
    cell.state = DealState(rawValue: dealState)
    cell.username = dealAnotherUsername
    cell.numberProduces = dealNumberProduces
    cell.date = dealDate
    cell.profilePictureURL = deal["anotherProfilePictureURL"] as? String
    cell.userImageTapped = userImageTapped
    cell.hasNewNotifications = trade > 0 || chat > 0
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return deals.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
}

































