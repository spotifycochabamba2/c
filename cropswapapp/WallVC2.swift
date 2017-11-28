//
//  WallVC2.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/10/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

public class WallVC2: UITableViewController {
  
  var wallOwnerId: String?
  public var sections = [Bool]()
  var posts = [(Post, Bool)]()
  var comments = [String: [Comment]]()
  var time = Date()
  
  let formatter = DateFormatter()
  
  
  var listenRecentPostHandlerId: UInt = 0
 
  deinit {
    if let userId = wallOwnerId {
      Post.unlistenRecenPosts(
        wallOwnerId: userId,
        time: time,
        handlerId: listenRecentPostHandlerId)
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    formatter.dateFormat = "MM/dd/yyyy"
    
    tableView.estimatedSectionHeaderHeight = 100
    tableView.rowHeight = 100
    tableView.estimatedRowHeight = UITableViewAutomaticDimension
    
    let nib = UINib(nibName: "WallSectionHeaderCell", bundle: nil)
    tableView.register(nib, forHeaderFooterViewReuseIdentifier: WallSectionHeaderCell.identifier)
    
    if let userId = wallOwnerId {
      SVProgressHUD.show()
      Post.getPostsOnce(byUserId: userId) { [weak self] (result) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        guard let this = self else { return }
        
        switch result {
        case .success(let postsFound):
          this.posts = postsFound.map { ($0, false) }
          DispatchQueue.main.async {
            this.tableView.reloadData()
          }
          
        case .fail(let error):
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          DispatchQueue.main.async {
            this.present(alert, animated: true)
          }
        }
      }
      
//      time = Date()
      listenRecentPostHandlerId = Post.listenRecentPosts(
        wallOwnerId: userId,
        fromTime: time,
        completion: { [weak self] (newPost) in
          guard let this = self else { return }
          
          var post = newPost
          User.getUser(byUserId: newPost.ownerId, completion: { (result) in
            switch result {
            case .success(let user):
              post.ownerUsername = user.username
              post.ownerProfilePictureURL = user.profilePictureURL
              
            case .fail(_):
              break
            }

            this.posts.insert((post, false), at: 0)
            
            let indexSet = IndexSet(integer: 0)
            
            if
              let currentUserId = User.currentUser?.uid,
              newPost.ownerId != currentUserId
            {
              this.tableView.insertSections(indexSet, with: .automatic)
            } else {
              this.tableView.insertSections(indexSet, with: .automatic)
              this.tableView.reloadSections(indexSet, with: .automatic)
            }
          })
      })
      
      _ = Post.listenDeletesOnPosts(
        wallOwnerId: userId,
        completion: { [weak self] (postDeleted) in
          guard let this = self else { return }
          
          let postIndex = this.posts.index(where: { (tuple) -> Bool in
            let post = tuple.0
            
            return postDeleted.id == post.id
          })
          

          if let index = postIndex {
            this.posts.remove(at: index)
            
//            let indexSet = IndexSet(integer: index)
//            this.tableView.deleteSections(indexSet, with: .automatic)
            UIView.transition(
              with: this.tableView,
              duration: 0.35,
              options: .transitionCrossDissolve,
              animations: { 
                this.tableView.reloadData()
              }
            )

          }
      })
      
      _ = Post.listenChangesOnPosts(
        wallOwnerId: userId,
        completion: { [weak self] (postChanged) in
          guard let this = self else { return }
          
          let postIndex = this.posts.index(where: { (tuple) -> Bool in
            let post = tuple.0
            
            return postChanged.id == post.id
          })
          
          if let index = postIndex {
            let expanded = this.posts[index].1
            var post = this.posts[index].0
            post.commentCounter = postChanged.commentCounter
            
            this.posts[index] = (post, expanded)
            
            if expanded {
              Comment.getComments(
                byPostId: post.id,
                completion: { [weak self] (result) in
                  
                  guard let this = self else { return }
                  
                  switch result {
                  case .success(let commentsFound):
                    this.comments[post.id] = commentsFound
//                    let indexSet = IndexSet(integer: index)
                    
                    DispatchQueue.main.async {
                      this.tableView.reloadData()
//                      this.tableView.reloadSections(indexSet, with: .automatic)
                    }
                    
                  case .fail(let error):
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    DispatchQueue.main.async {
                      this.present(alert, animated: true)
                    }
                  }
                })
            } else {
            
//              let indexSet = IndexSet(integer: index)
              DispatchQueue.main.async {
                this.tableView.reloadData()
//                this.tableView.reloadSections(indexSet, with: .automatic)
              }
            }
            
          }
      })

    }
  }
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.WallToComment {
      let nc = segue.destination as? UINavigationController
      let vc = nc?.viewControllers.first as? WallCommentVC
      
      let post = sender as? Post
      let postId = post?.id
      
      vc?.commenterId = User.currentUser?.uid
      vc?.postId = postId
      vc?.wallOwnerId = wallOwnerId
    } else if segue.identifier == Storyboard.WallToShowImage {
      let vc = segue.destination as? ProduceImageZoomableVC
      vc?.customImage = sender as? UIImage
      vc?.hideCloseButton = false
    }
  }
  
  public func didCommentTouch(_ section: Int) {
    let post = posts[section].0
    
    performSegue(withIdentifier: Storyboard.WallToComment, sender: post)
  }
  
  public func didSectionHide(_ section: Int, _ enabled: Bool) {
    if section >= 0 {
      let post = posts[section].0
      
      posts[section].1 = enabled
      
      if enabled {
        Comment.getComments(
          byPostId: post.id,
          completion: { [weak self] (result) in
            
            guard let this = self else { return }
                        
            switch result {
            case .success(let commentsFound):
              this.comments[post.id] = commentsFound
              let indexSet = IndexSet(integer: section)
              
              DispatchQueue.main.async {
                this.tableView.reloadSections(indexSet, with: .automatic)
              }
              
            case .fail(let error):
              let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              DispatchQueue.main.async {
                this.present(alert, animated: true)
              }
            }
          })
      } else {
        let numberRows = super.tableView(tableView, numberOfRowsInSection: section)
        
        var indexPaths = [IndexPath]()
        
        for row in 0..<numberRows {
          indexPaths.append(IndexPath(row: row, section: section))
        }
        
        
        //        tableView.reloadRows(at: indexPaths, with: .none)
        let indexSet = IndexSet(integer: section)
        tableView.reloadSections(indexSet, with: .automatic)
      }
    }
  }
  
  func reloadSection(section: Int) {
    let numberRows = super.tableView(tableView, numberOfRowsInSection: section)
    
    var indexPaths = [IndexPath]()
    
    for row in 0..<numberRows {
      indexPaths.append(IndexPath(row: row, section: section))
    }
    
    tableView.reloadRows(at: indexPaths, with: .automatic)
//    tableView.reloadData()
    
//    let indexSet = IndexSet(integer: section)
//    tableView.reloadSections(indexSet, with: .automatic)
    
//
  }
  
}


extension WallVC2 {
  
  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let shown = posts[indexPath.section].1
    
    if shown {
      return UITableViewAutomaticDimension
    } else {
      return 0
    }
  }
  
  public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  public override func numberOfSections(in tableView: UITableView) -> Int {
    return posts.count
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let postId = posts[section].0.id
    
    return comments[postId]?.count ?? 0
  }
  
  func showAlert(_ alert: UIAlertController) {
    present(alert, animated: true)
  }
  
  func didImageTapAtHeader(_ image: UIImage) {
    performSegue(withIdentifier: Storyboard.WallToShowImage, sender: image)
  }
  
  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: WallSectionHeaderCell.identifier) as! WallSectionHeaderCell

    let isEnabled = posts[section].1
    let post = posts[section].0
    
    header.currentView.backgroundColor = .white
    header.currentView.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    
    header.showAlert = showAlert
    header.didImageTap = didImageTapAtHeader
    header.currentView.layer.shadowColor = UIColor.lightGray.cgColor
    header.currentView.layer.shadowOffset = CGSize(width: 0, height: 0)
    header.currentView.layer.shadowRadius = 3
    header.currentView.layer.shadowOpacity = 0.5
    
    header.wallOwnerId = wallOwnerId
    header.post = post
    header.sectionEnabled = isEnabled
    header.sectionIndex = section
    header.didSectionHide = didSectionHide
    header.didCommentTouch = didCommentTouch
    
    header.rootStackView.updateConstraintsIfNeeded()
    header.rootStackView.layoutIfNeeded()
    header.rootStackView.setNeedsLayout()
    header.rootStackView.setNeedsDisplay()
    
    header.messageLabel.updateConstraintsIfNeeded()
    header.messageLabel.setNeedsLayout()
    header.messageLabel.layoutIfNeeded()

    header.layoutIfNeeded()
    header.setNeedsLayout()
    header.layoutSubviews()
    
    header.contentView.updateConstraintsIfNeeded()
    header.contentView.layoutIfNeeded()
    header.contentView.setNeedsLayout()
    
    
//    header.layoutSubviews()
    
    return header
  }
  
  public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    let post = posts[indexPath.section]
    let comment = comments[post.0.id]?[indexPath.row]
    
    if let commenterId = comment?.ownerId,
       let wallOwnerId = wallOwnerId,
      let currentUserId = User.currentUser?.uid {
      return canSeeDeleteButton(
        commenterId: commenterId,
        wallOwnerId: wallOwnerId,
        currentUserId: currentUserId
      )
    } else {
      return false
    }
    

  }
  
  func canSeeDeleteButton(commenterId: String, wallOwnerId: String, currentUserId: String) -> Bool {
    return
      currentUserId == commenterId
        ||
        currentUserId == wallOwnerId
  }
  
  public override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let post = posts[indexPath.section].0
    let comment = comments[post.id]?[indexPath.row]
    
    let deleteAction = UITableViewRowAction(
      style: .destructive,
      title: "Delete") { [weak self] (action, indexPath) in
        guard let this = self else { return }
        
        let alert = UIAlertController(
          title: "Confirmation",
          message: "Are you sure want to delete this comment?",
          preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
          
          DispatchQueue.main.async {
            this.tableView.setEditing(false, animated: true)
          }
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
          
          if let wallOwnerId = this.wallOwnerId,
             let comment = comment
          {
            Comment.deleteComment(
              wallOwnerId: wallOwnerId,
              postId: post.id,
              commentId: comment.id,
              completion: { (error) in
                
            })
          }
        }))
        
        this.present(alert, animated: true)
    }
    
    return [deleteAction]
  }
  
  public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      
    }
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: WallPostCell2.identifier, for: indexPath) as! WallPostCell2
    let post = posts[indexPath.section]
    let comment = comments[post.0.id]?[indexPath.row]
    
    cell.comment = comment
    
    return cell
  }
  
}




























