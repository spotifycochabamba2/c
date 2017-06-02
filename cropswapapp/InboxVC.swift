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
}

// View Life Cycle
extension InboxVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let userId = User.currentUser?.uid {
      SVProgressHUD.show()
      Inbox.getInbox(byUserId: userId, completion: { [weak self] (items) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        self?.items = items
        })
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
}


// UITableViewController delegates
extension InboxVC {
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




















