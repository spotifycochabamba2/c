//
//  TagListVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/13/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD


class TagListChildVC: UITableViewController {
  let estimatedRowHeight:CGFloat = 95.0
  var tagList = [[String: Any]]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.tableView.reloadData()
      }
    }
  }
  
  
  
  var tagsAlreadySelected = [String: Any]()
}

extension TagListChildVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    

    
    SVProgressHUD.show()
    Produce.getTags { [weak self] (tags) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      
      print(tags.count)
      print(tags)
      self?.tagList = tags
    }
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = estimatedRowHeight
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.TagListToChooseTags {
//      let nc = segue.destination as? UINavigationController
//      let vc = nc?.viewControllers.first as? ChooseTagsContainerVC
      let vc = segue.destination as? ChooseTagsContainerVC
      let dictionary = sender as? [String: Any]
      vc?.tagList = dictionary
      vc?.tagsSelected = tagsAlreadySelected[dictionary?.keys.first ?? ""] as? [String: Any] ?? [String: Any]()
      vc?.tagListKey = dictionary?.keys.first
      vc?.didAddItems = didAddItems
    }
  }
}

extension TagListChildVC {
  public func backButtonTouched() {
    dismiss(animated: true)
  }
  
  public func didAddItems(_ groupKey: String, _ tags: [String: Any]) -> Void {
    tagsAlreadySelected[groupKey] = tags
    
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }
}

extension TagListChildVC {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let tags = tagList[indexPath.row]
    
    performSegue(withIdentifier: Storyboard.TagListToChooseTags, sender: tags)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    cell.setNeedsDisplay()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tagList.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TagListCell.identifier, for: indexPath) as! TagListCell
    let tag = tagList[indexPath.row]
    
    cell.tagsAlreadySelected = tagsAlreadySelected
    cell.tagList = tag
//    cell.layoutIfNeeded()
    
    return cell
  }
  
}
