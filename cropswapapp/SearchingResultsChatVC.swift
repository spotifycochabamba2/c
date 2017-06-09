//
//  SearchingResultsChat.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/7/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchingResultsChatVC: UITableViewController {
  var users = [[String: Any]]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.tableView.reloadData()
      }
    }
  }
}

extension SearchingResultsChatVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.SearchingChatResultsToChat {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TradeChatVC
      
      let values = sender as? [String: Any]
      
      vc?.anotherUserId = values?["toUserId"] as? String
      vc?.anotherUsername = values?["toUserName"] as? String
      vc?.dealId = values?["inboxId"] as? String
      vc?.usedForInbox = true
    }
  }
}

extension SearchingResultsChatVC {
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let userSelected = users[indexPath.row]
    
    guard let fromUserId = User.currentUser?.uid else {
      let alert = UIAlertController(title: "Error", message: "your id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    guard let toUserId = userSelected["id"] as? String else {
      let alert = UIAlertController(title: "Error", message: "id of the user selected not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    guard let toUserName = userSelected["name"] as? String else {
      let alert = UIAlertController(title: "Error", message: "name of the user selected not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    if fromUserId != toUserId {
      SVProgressHUD.show()
      Inbox.getOrCreateInboxId(
        fromUserId: fromUserId,
        toUserId: toUserId) { (inboxId) in
          DispatchQueue.main.async { [weak self] in
            SVProgressHUD.dismiss()
            
            var values = [String: Any]()
            values["toUserId"] = toUserId
            values["toUserName"] = toUserName
            values["inboxId"] = inboxId
            
            self?.performSegue(withIdentifier: Storyboard.SearchingChatResultsToChat, sender: values)
          }
      }
    } else {
      let alert = UIAlertController(title: "Info", message: "Sorry you can't send a message to yourself", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SearchingResultCell.identifier, for: indexPath) as! SearchingResultCell
    let user = users[indexPath.row]
    
    cell.user = user
    
    return cell
  }
}

extension SearchingResultsChatVC: UISearchControllerDelegate, UISearchBarDelegate {
  
  func willPresentSearchController(_ searchController: UISearchController) {
    SVProgressHUD.dismiss()
  }
  
  func willDismissSearchController(_ searchController: UISearchController) {
    SVProgressHUD.dismiss()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    let text = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    if text.characters.count >= 1 {
      print("searching")
      SVProgressHUD.show()
      
      User.searchFor(filter: text, completion: { [weak self] (users) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        self?.users = users
      })
    } else {
      let alert = UIAlertController(title: "Info", message: "Please enter at least 1 or more characters", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    users.removeAll()
  }
  
}







































