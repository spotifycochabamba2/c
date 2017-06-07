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
}

// View Life Cycle
extension InboxVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavHeaderTitle(title: "Chat", color: UIColor.black)
    
    if let userId = User.currentUser?.uid {
      SVProgressHUD.show()
      
      Inbox.getInbox(byUserId: userId, completion: { [weak self] (items) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        print(" creative from once")
        self?.items = items.filter({ (item) -> Bool in
          let anotherUserId = item["anotherUserId"] as? String
          
          return anotherUserId != nil
        })
      })
      
      listenUpdateInboxHandlerId = Inbox.listenUpdatesInbox(byUserId: userId, completion: { [weak self] (numberOfNotifications) in
        Inbox.getInbox(byUserId: userId, completion: { (items) in
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
      Inbox.getInbox(byUserId: userId, completion: { [weak self] (items) in
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



















