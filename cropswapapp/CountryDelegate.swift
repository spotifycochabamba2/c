//
//  CountryDelegate.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/21/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class CountryDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
  
  var tableView: UITableView!
  var countryCellId = "countryCellId"
  
  var filteredCountries = [String]()
  var countries = [String]()
  
  var backgroundViewCell: UIView!
  var fontCell: UIFont!
  
  var didCountrySelect: (String) -> Void = { _ in }
  
  init(tableView: UITableView) {
    super.init()
    self.tableView = tableView
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    backgroundViewCell = UIView()
    backgroundViewCell.backgroundColor = UIColor.cropswapRed
    
    fontCell = UIFont(name: "Montserrat-Regular", size: 18)
  }
  
  public func setup() {
    for code in NSLocale.isoCountryCodes as [String] {
      let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
      let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
      countries.append(name)
      filteredCountries.append(name)
      
      tableView.reloadData()
    }
  }
  
  public func clear() {
    filteredCountries.removeAll()
    tableView.reloadData()
  }
  
  public func filterCountries(byText text: String) {
    filteredCountries.removeAll()
    
    if text.characters.count > 0 {
      
      for country in countries {
        let countryLowered = country.lowercased()
        let substringRange = (countryLowered as NSString).range(of: text.lowercased())
        
        if substringRange.location == 0 {
          filteredCountries.append(country)
        }
      }
      
    } else {
      filteredCountries = countries
    }
    
    tableView.reloadData()
  }
}

extension CountryDelegate {
  
  @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let country = filteredCountries[indexPath.row]
    didCountrySelect(country)
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: countryCellId, for: indexPath)
    let country = filteredCountries[indexPath.row]
    
    cell.textLabel?.text = country
    cell.textLabel?.font = fontCell
    cell.textLabel?.textColor = .black
    cell.selectedBackgroundView = backgroundViewCell
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredCountries.count
  }
  
}





















