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
  var typeSelected: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let typeSelected = typeSelected {
      
      if typeSelected == ProduceStartType.seed.rawValue {
        units.append(("min 5 seeds", false))
        units.append(("min 10 seeds", false))
        units.append(("min 15 seeds", false))
        units.append(("min 25 seeds", false))
        units.append(("min 50 seeds", false))
        units.append(("min 75 seeds", false))
        units.append(("min 100 seeds", false))
        units.append(("min 150 seeds", false))
        units.append(("min 250 seeds", false))
        units.append(("min 1000 seeds", false))
      } else if typeSelected == ProduceStartType.plant.rawValue {
        units.append(("single plant", false))
        units.append(("six pack", false))
      } else {
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
      }
      
    } else {
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
    }
    
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
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: ChooseDetailCell.cellId, for: indexPath) as! ChooseDetailCell
    let unit = units[indexPath.row]
    
    cell.tagNameLabel.text = unit.0
    cell.isCellSelected = unit.1
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return units.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
//  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    let unit = units[indexPath.row]
//    let unitCell = cell as? ChooseDetailCell
//    
//    unitCell?.tagNameLabel.text = unit.0
//    unitCell?.isCellSelected = unit.1
//  }
  
}






























