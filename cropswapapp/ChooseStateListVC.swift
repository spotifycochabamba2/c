//
//  ChooseStateListVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/19/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ChooseStateListVC: UITableViewController {
  var stateSelected: String?
  
  var states = [(String, Bool)]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    states.append(("Seed", false))
    states.append(("Seeding", false))
    states.append(("Flowering", false))
    states.append(("Ready For Sale", false))
    
    view.backgroundColor = .clear
    tableView.backgroundColor = .clear
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    var index = 0
    
    for _ in states {
      states[index].1 = false
      index += 1
    }
    
    states[indexPath.row].1 = !states[indexPath.row].1
    
    stateSelected = states[indexPath.row].0
      
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let state = states[indexPath.row]
    let stateCell = cell as? ChooseDetailCell
    
    stateCell?.tagNameLabel.text = state.0
    stateCell?.isCellSelected = state.1
  }
}
