//
//  ProductTypesDelegate.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProduceTypesDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
  
  var tableView: UITableView!
  let productTypeCellId = "ProductTypeCellId"
  
  var filteredProduceTypes = [(name: String, quantityType: String)]()
  var produceTypes = [(name: String, quantityType: String)]()
  
  var didProduceTypeSelect: ((name: String, quantityType: String)) -> Void = { _ in }
  
  var backgroundViewCell: UIView!
  var fontCell: UIFont!
  
  init(tableView: UITableView) {
    super.init()
    
    self.tableView = tableView
    
    tableView.delegate = self
    tableView.dataSource = self
    
    backgroundViewCell = UIView()
    backgroundViewCell.backgroundColor = UIColor.cropswapRed
    
    fontCell = UIFont(name: "Montserrat-Regular", size: 18)
  }
  
  public func setup() {
    
//    tableView.layer.borderWidth = 1.0
//    tableView.layer.borderColor = UIColor.cropswapRed.cgColor

    SVProgressHUD.show()
    Produce.getProduceTypes { [weak self] types in
      SVProgressHUD.dismiss()
      
      self?.filteredProduceTypes = types
      self?.produceTypes = types
      
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
    
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    let type = filteredProduceTypes[indexPath.row]
    didProduceTypeSelect(type)
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: productTypeCellId, for: indexPath)
    let type = filteredProduceTypes[indexPath.row]
    
    cell.textLabel?.text = type.name
    cell.textLabel?.font = fontCell
    cell.textLabel?.textColor = UIColor.black
    cell.selectedBackgroundView = backgroundViewCell
    
    return cell
  }
  
  public func clear() {
    filteredProduceTypes.removeAll()
    tableView.reloadData()
  }
  
  public func filterProduces(byText text: String) {
    
    filteredProduceTypes.removeAll()
    
    if text.characters.count > 0 {
      for produceType in produceTypes {
        let produceTypeLowered = produceType.name.lowercased()
        let substringRange = (produceTypeLowered as NSString).range(of: text)
        
        if substringRange.location == 0 {
          filteredProduceTypes.append(produceType)
        }
      }
    } else {
      filteredProduceTypes = produceTypes
    }
    
    tableView.reloadData()
  }


  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return filteredProduceTypes.count
  }

}







































