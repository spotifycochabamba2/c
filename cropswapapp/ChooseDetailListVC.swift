//
//  ChooseDetailListVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/17/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChooseDetailListVC: UITableViewController {
  
  var tags = [(String, Bool, Int, String)]()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    SVProgressHUD.show()
    Produce.getDetails { [weak self] (details) in
      SVProgressHUD.dismiss()

      self?.tags = details.flatMap {
        let name = $0["name"] as! String
        let priority = $0["priority"] as! Int
        let key = $0["key"] as! String
        
        
        return (name, false, priority, key)
      }
      
      self?.tableView.reloadData()
    }
    
    view.backgroundColor = .clear
    tableView.backgroundColor = .clear
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tags[indexPath.row].1 = !tags[indexPath.row].1
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ChooseDetailCell.cellId, for: indexPath) as! ChooseDetailCell
    
    let tag = tags[indexPath.row]
    
    cell.isCellSelected = tag.1
    cell.name = tag.0
    cell.priority = tag.2
    
    return cell
  }
  
}
































 
