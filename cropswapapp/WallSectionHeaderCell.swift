//
//  WallSectionHeaderCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/10/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class WallSectionHeaderCell: UITableViewHeaderFooterView {
  
  @IBOutlet weak var rootStackView: UIStackView!
  @IBOutlet weak var deletePostButton: UIButton!
  @IBOutlet weak var commentsButton: UIButton!
  @IBOutlet weak var profileImageView: UIImageViewCircular!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var pictureImageView: UIImageView! {
    didSet {
      pictureImageView.isUserInteractionEnabled = true
      
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
      tapGesture.numberOfTapsRequired = 1
      tapGesture.numberOfTouchesRequired = 1
      
      pictureImageView.addGestureRecognizer(tapGesture)
    }
  }
  
  func profileImageTapped() {
    
    if let image = pictureImageView.image {
      didImageTap(image)
    }
  }
  
  var sectionIndex = -1
  static let identifier = "WallSectionHeaderCellId"
  var sectionEnabled = false
  
  var showAlert: (UIAlertController) -> Void = { _ in }
  var didSectionHide: (Int, Bool) -> Void = { _, _ in }
  var didCommentTouch: (Int) -> Void = { _ in }
  var didImageTap: (UIImage) -> Void = { _ in }
  
  var wallOwnerId: String?
  var post: Post? {
    didSet {
      if let post = post {
        pictureImageView.isHidden = true

        deletePostButton.isHidden = true
        
        if let url = URL(string: post.attachedImageURL ?? "") {
          pictureImageView.isHidden = false
          pictureImageView.sd_setImage(with: url)
        }
        
        
        if let wallOwnerId = wallOwnerId,
           let currentUserId = User.currentUser?.uid
        {
          if canSeeDeleteButton(
            posterId: post.ownerId,
            wallOwnerId: wallOwnerId,
            currentUserId: currentUserId
            )
          {
            deletePostButton.isHidden = false
          }
        }
        
        commentsButton.setTitle("\(post.commentCounter) Comments", for: .normal)
        
        if post.commentCounter == 0 {
          commentsButton.isEnabled = false
          commentsButton.alpha = 0.5
        } else {
          commentsButton.isEnabled = true
          commentsButton.alpha = 1
        }
        
        usernameLabel.text = post.ownerUsername
        dateLabel.text = Utils.relativePast(for: post.date)
//        dateLabel.text = Utils.dateFormatter.string(from: post.date)
        messageLabel.text = post.text
        
        if let url = URL(string: post.ownerProfilePictureURL ?? "") {
          profileImageView.sd_setImage(with: url)
        }
        
      }
    }
  }
  
  @IBOutlet weak var currentView: UIView!
  
  public override func prepareForReuse() {
    messageLabel.text = ""
  }
  
  @IBAction func commentButtonTouched(_ sender: AnyObject) {
    print(!sectionEnabled)
//    commentsButton.setTitle("WTF?", for: .normal)
    commentsButton.isEnabled = false
    commentsButton.alpha = 0.5
    sectionEnabled = !sectionEnabled
    didSectionHide(sectionIndex, sectionEnabled)
  }
  
  @IBAction func openCommentButtonTouched() {
    didCommentTouch(sectionIndex)
  }
  
  @IBAction func deletePostButtonTouched() {
    guard let post = post else {
      let alert = UIAlertController(
        title: "Error",
        message: "No post found.",
        preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      showAlert(alert)
      return
    }
    
    guard let wallOwnerId = wallOwnerId else {
      let alert = UIAlertController(title: "Error", message: "No wall owner id.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      showAlert(alert)
      return
    }
    
    let confirmationAlert = UIAlertController(
      title: "Confirmation",
      message: "Are you sure want to delete this post?",
      preferredStyle: .alert
    )
    
    confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .default))
    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
      Post.deletePost(
        wallOwnerId: wallOwnerId,
        postId: post.id,
        completion: { [weak self] (error) in
          guard let this = self else { return }
          
          if let error = error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            this.showAlert(alert)
          }
        })
    }))
    
    showAlert(confirmationAlert)
  }
  
  
  func canSeeDeleteButton(posterId: String, wallOwnerId: String, currentUserId: String) -> Bool {
    return
          currentUserId == posterId
                ||
          currentUserId == wallOwnerId
  }
}





























