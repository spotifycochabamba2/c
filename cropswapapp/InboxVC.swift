//
//  InboxVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/1/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

// Properties
class InboxVC: UITableViewController {
  
  var searchingResultsChatVC: SearchingResultsChatVC!
  var usersSearchController: UISearchController!
  
  var items = [[String: Any]]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.tableView.reloadData()
      }
    }
  }
  
  var listenUpdateInboxHandlerId: UInt = 0
  
  deinit {
    if let userId = User.currentUser?.uid {
      Inbox.unListenUpdateInbox(byUserId: userId, handlerId: listenUpdateInboxHandlerId)
    }
  }
  
//  func dismissModals(notification: Notification) {
//    
//    DispatchQueue.main.async { [weak self] in
//      self?.dismiss(animated: true)
//      self?.tabBarController?.selectedIndex = 1
//    }
////    NotificationCenter.default.removeObserver(
////      self,
////      name: NSNotification.Name(rawValue: "dismissModals"),
////      object: nil
////    )
//  }
  
}

// View Life Cycle
extension InboxVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    NotificationCenter.default.addObserver(
//      self,
//      selector: #selector(dismissModals(notification:)),
//      name: NSNotification.Name(rawValue: "dismissModals"),
//      object: nil
//    )
    
    let rightButtonIcon = setNavIcon(imageName: "add-user-chat", size: CGSize(width: 40, height: 40), position: .right)
    rightButtonIcon.addTarget(self, action: #selector(rightButtonTouched), for: .touchUpInside)
    
    setupUsersSearchController()
    
    setNavHeaderTitle(title: "Messages", color: UIColor.black)
    
    if let userId = User.currentUser?.uid {
      SVProgressHUD.show()
      
      Inbox.getInbox(byUserId: userId, completion: { [weak self] (error, items) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        self?.items = items.filter({ (item) -> Bool in
          let anotherUserId = item["anotherUserId"] as? String
          
          return anotherUserId != nil
        })
      })
      
      listenUpdateInboxHandlerId = Inbox.listenUpdatesInbox(byUserId: userId, completion: { [weak self] (numberOfNotifications) in
        Inbox.getInbox(byUserId: userId, completion: { (error, items) in
          self?.items = items.filter({ (item) -> Bool in
            let anotherUserId = item["anotherUserId"] as? String
            
            return anotherUserId != nil
          })
        })
      })
    }
  }
  
  func updateInboxVC() {
    if let userId = User.currentUser?.uid {
      Inbox.getInbox(byUserId: userId, completion: { [weak self] (error, items) in
        self?.items = items.filter({ (item) -> Bool in
          let anotherUserId = item["anotherUserId"] as? String
          
          return anotherUserId != nil
        })
      })
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.InboxToChat {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TradeChatVC
      
      let item = sender as? [String: Any]
      let username = item?["name"] as? String
      let userId = item?["anotherUserId"] as? String
      let inboxId = item?["inboxId"] as? String
      
      vc?.anotherUserId = userId
      vc?.anotherUsername = username
      vc?.dealId = inboxId
      vc?.usedForInbox = true
      vc?.updateInboxVC = updateInboxVC
      vc?.tradeListButtonWasTouchedOnChat = tradeListButtonWasTouchedOnChat
      
      if let currentUserId = User.currentUser?.uid,
        let anotherUserId = userId {
        Inbox.clearInbox(
          ofUserId: currentUserId,
          withUserId: anotherUserId,
          completion: {
            
        })
      }
    }
  }
}


// UITableViewController delegates
extension InboxVC {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    
    performSegue(withIdentifier: Storyboard.InboxToChat, sender: item)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: InboxCell.identifier, for: indexPath) as! InboxCell
    let item = items[indexPath.row]
    
    cell.inbox = item
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
}

extension InboxVC {
  
  func rightButtonTouched() {
    tabBarController?.present(usersSearchController, animated: true, completion: {
      
    })
  }
  
  func setupUsersSearchController() {
    searchingResultsChatVC = UIStoryboard(name: "SearchingResultsChat", bundle: nil).instantiateViewController(withIdentifier: "SearchingResultsChatVC") as! SearchingResultsChatVC
    searchingResultsChatVC.view.frame = view.frame
    
    usersSearchController = UISearchController(searchResultsController: searchingResultsChatVC)
    
    usersSearchController.dimsBackgroundDuringPresentation = true
    usersSearchController.searchBar.sizeToFit()
    
    usersSearchController.searchBar.delegate = searchingResultsChatVC
    usersSearchController.delegate = searchingResultsChatVC    
    
    definesPresentationContext = false
  }
  
  func tradeListButtonWasTouchedOnChat() {
    tabBarController?.selectedIndex = 1
  }
  
}

extension InboxVC {
  
}
















