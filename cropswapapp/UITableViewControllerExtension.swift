//
//  UITableViewController.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/4/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

extension UITableViewController {
  func scroll(to view: UIView) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
      var scrollRect = view.frame
      scrollRect = self.tableView.convert(scrollRect, from: view.superview)
      self.tableView.scrollRectToVisible(scrollRect, animated: true)
    }
  }
}
