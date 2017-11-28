//
//  WallVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class WallVC: UITableViewController {
  
  var posts = [(Post, Bool)]()
  var comments = [String: [Comment]]()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableViewAutomaticDimension
//    self.posts = Post.getPosts().map { return ($0, false) }
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//      self.posts = Post.getPosts().map { return ($0, false) }
//      self.tableView.reloadData()
//    }
    
  }
  
  
}

extension WallVC {
  
  func didCommentButtonTap(_ index: Int, commentsExpanded: Bool) {
    posts[index].1 = commentsExpanded
    let indexPath = IndexPath(row: index, section: 0)
    
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    let cell = super.tableView(tableView, cellForRowAt: indexPath) as! WallPostCell
//    cell.commentStackView.setNeedsLayout()
//    cell.commentStackView.setNeedsDisplay()
    
    return UITableViewAutomaticDimension
  }
  
  public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: WallPostCell.identifier, for: indexPath) as! WallPostCell
    let post = posts[indexPath.row]
    
    cell.index = indexPath.row
    cell.post = post.0
    cell.commentsExpanded = post.1
    cell.didCommentButtonTap = didCommentButtonTap
//    
//    cell.commentStackView.setNeedsLayout()
//    cell.commentStackView.setNeedsDisplay()
    
    return cell
  }
  
}











































