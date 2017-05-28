//
//  ChooseUnitListVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/27/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ChooseUnitListVC: UITableViewController {
  var unitSelected: String?
  var units = [(String, Bool)]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    units.append(("each", false))
    units.append(("bunches", false))
    units.append(("handfuls", false))
    units.append(("cups", false))
    units.append(("leaves", false))
    units.append(("stems", false))
    units.append(("stalks", false))
    units.append(("shoots", false))
    units.append(("flowers", false))
    units.append(("tubers", false))
    units.append(("ears", false))
    units.append(("roots", false))
    units.append(("bulbs", false))
    units.append(("heads", false))
    units.append(("ounces", false))
    units.append(("grams", false))
    units.append(("pounds", false))
    units.append(("kilo", false))
    
    view.backgroundColor = .clear
    tableView.backgroundColor = .clear
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    var index = 0
    
    for _ in units {
      units[index].1 = false
      index += 1
    }
    
    units[indexPath.row].1 = !units[indexPath.row].1
    
    unitSelected = units[indexPath.row].0
    
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let unit = units[indexPath.row]
    let unitCell = cell as? ChooseDetailCell
    
    unitCell?.tagNameLabel.text = unit.0
    unitCell?.isCellSelected = unit.1
  }
  
}






























