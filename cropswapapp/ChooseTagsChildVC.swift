//
//  ChooseTagsChildVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/13/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class ChooseTagsChildVC: UITableViewController {
  var tagListKey: String?
  var tagsDictionary: [String: Any]?
  var tagsSelected: [String: Any]?
  var tagsArray = [([String: Any], Bool)]()
  let cellHeight: CGFloat = 60.0
  
  public override func viewDidLoad() {
    super.viewDidLoad()
//    tableView.rowHeight = UITableViewAutomaticDimension
//    tableView.estimatedRowHeight = estimatedRowHeight
    
    automaticallyAdjustsScrollViewInsets = false
    
    if let tags = tagsDictionary?[tagListKey ?? ""] as? [String: Any] {
      for (k, v) in tags {
        if var item = v as? [String: Any] {
          item["id"] = k
          
          var selected = false
          
          if let tag = tagsSelected?[k] as? [String: Any],
             let _ = tag["name"] as? String
          {
            selected = true
          }
          
          tagsArray.append((item, selected))
        }
      }
    }    
  }

}

extension ChooseTagsChildVC {
  
  public func getTagsSelected() -> (groupKey: String, tags: [[String: Any]]) {
    var tagsSelected = [[String: Any]]()
    
    tagsArray.forEach {
      if $0.1 {
        tagsSelected.append($0.0)
      }
    }
    
    return (groupKey: tagListKey ?? "", tags: tagsSelected)
  }
}

extension ChooseTagsChildVC {
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(indexPath.row)
  }
  
  public override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    
    tagsArray[indexPath.row].1 = !tagsArray[indexPath.row].1
    tableView.reloadData()
    return false
  }
//
  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tagsArray.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ChooseTagsCell.identifier, for: indexPath) as! ChooseTagsCell
    let currentTag = tagsArray[indexPath.row]
    
    cell.currentTag = currentTag.0
    cell.isChecked = currentTag.1
    
    return cell
  }
  
}

























