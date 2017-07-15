//
//  WallPostCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class WallPostCell: UITableViewCell {
  
  static let identifier = "WallPostCellId"
  var index: Int = 0
  @IBOutlet weak var commentStackView: UIStackView!
  
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var userImageView: UIImageView!
//  @IBOutlet weak var postPictureImageView: UIImageView!
  @IBOutlet weak var messageLabel: UILabel!
  var didCommentButtonTap: (Int, Bool) -> Void = { _ in }
  var commentViews = [UIView]()
  var rootStackView: UIStackView!
  
  var post: Post? {
    didSet {
      if let post = post {
        messageLabel.text = post.text
        usernameLabel.text = post.ownerUsername
        dateLabel.text = "\(post.date.timeIntervalSince1970)"
        
        if let url = URL(string: post.ownerProfilePictureURL ?? "") {
          userImageView.sd_setImage(with: url)
        }
      }
    }
  }
  
  var commentsExpanded = false {
    didSet {
//      if commentsExpanded {
//        
//        getComments { [weak self] in
//          guard let this = self else {
//            return
//          }
//          
//          this.didCommentButtonTap(this.index, true)
//        }
//
//      } else {
//        cleanCommentViews()
//      }
    }
  }

  func getComments(completion: @escaping () -> Void) {
//    let comments = Comment.getComments()
//
//    comments.forEach {
//      let view = createCommentView($0)
//      commentViews.append(view)
////      commentStackView.addArrangedSubview(view)
//    }
//    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//      completion()
//    }
  }
  
  @IBAction func commentButtonTapped() {
    commentsExpanded = !commentsExpanded
    
    if commentsExpanded {
      getComments { [weak self] in
        guard let this = self else {
          return
        }
        
        DispatchQueue.main.async {
          this.didCommentButtonTap(this.index, true)
        }
      }
    } else {
      cleanCommentViews()
      didCommentButtonTap(index, false)
    }
  }
  
  func cleanCommentViews() {
    commentViews.forEach {
      commentStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
    commentViews.removeAll()
  }
  
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    commentsExpanded = false
    
    usernameLabel.text = "Loading"
    dateLabel.text = "Loading"
    userImageView.image = nil
    messageLabel.text = "Loading"
    
    cleanCommentViews()
  }
}


extension WallPostCell {
  func createCommentView(_ comment: Comment) -> UIStackView {
    
    let spacingView = UIView()
    spacingView.backgroundColor = .red
    spacingView.translatesAutoresizingMaskIntoConstraints = false
//    let spacingWidthConstraint = spacingView.widthAnchor.constraint(lessThanOrEqualToConstant: 10)
    let spacingWidthConstraint = spacingView.widthAnchor.constraint(equalToConstant: 20)
    spacingWidthConstraint.priority = 999
    spacingWidthConstraint.isActive = true
    
    
    // ROOT STACK VIEW
    rootStackView = UIStackView()
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    commentStackView.addArrangedSubview(rootStackView)
    
//    let rootStackViewWidthConstraint = rootStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
    
//    let rootStackViewTopConstraint = rootStackView.topAnchor.constraint(equalTo: commentStackView.topAnchor, constant: 0)
//    let rootStackViewLeftConstraint = rootStackView.leftAnchor.constraint(equalTo: commentStackView.leftAnchor, constant: 0)
//    let rootStackViewRightConstraint = rootStackView.rightAnchor.constraint(equalTo: commentStackView.rightAnchor, constant: 0)
//
//    rootStackViewTopConstraint.isActive = true
//    rootStackViewLeftConstraint.isActive = true
//    rootStackViewRightConstraint.isActive = true
//    rootStackViewWidthConstraint.isActive = true
    
    rootStackView.alignment = .top
    rootStackView.distribution = .fillProportionally
    rootStackView.axis = .horizontal
    rootStackView.accessibilityIdentifier = "rootStackView"
    
    // IMAGE
    let profileImageView = UIImageViewCircular()
    profileImageView.accessibilityIdentifier = "profileImageView"
    profileImageView.backgroundColor = UIColor.lightGray
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
//    let widthConstraint = profileImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 40)
    let widthConstraint = profileImageView.widthAnchor.constraint(equalToConstant: 40)
//    widthConstraint.priority = 900
    widthConstraint.isActive = true

    
    
    let heightConstraint = profileImageView.heightAnchor.constraint(equalToConstant: 40)
//    let heightConstraint = profileImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
//    heightConstraint.priority = 900
    heightConstraint.isActive = true
    
//    rootStackView.addArrangedSubview(profileImageView)
    
    if let url = URL(string: comment.ownerProfilePictureURL ?? "") {
      profileImageView.sd_setImage(with: url)
    }

    // BASE STACKVIEW
    let baseStackView = UIStackView()
    baseStackView.axis = .vertical
    baseStackView.spacing = 5
    baseStackView.accessibilityIdentifier = "baseStackView"
    
    // TEXT
    let textLabel = UILabel()
    textLabel.font = Utils.textFont
    textLabel.numberOfLines = 0
    textLabel.text = comment.text
    
    // USERNAME STACKVIEW
    let usernameStackView = UIStackView()
    usernameStackView.axis = .horizontal
    usernameStackView.setContentCompressionResistancePriority(1000, for: .horizontal)
    
    // USERNAME
    let usernameLabel = UILabel()
    usernameLabel.font = Utils.usernameFont
    usernameLabel.textAlignment = .left
    usernameLabel.text = comment.ownerUsername
    usernameLabel.setContentCompressionResistancePriority(999, for: .horizontal)
    usernameStackView.addArrangedSubview(usernameLabel)
    
    // DATE
    let dateLabel = UILabel()
    dateLabel.font = Utils.dateFont
    dateLabel.textAlignment = .right
    dateLabel.setContentCompressionResistancePriority(1001, for: .horizontal)
    dateLabel.text = "\(comment.date.timeIntervalSince1970)"
    
    usernameStackView.addArrangedSubview(dateLabel)
    
    baseStackView.addArrangedSubview(usernameStackView)
    baseStackView.addArrangedSubview(textLabel)
    
//    rootStackView.addArrangedSubview(profileImageView)
//    rootStackView.addArrangedSubview(spacingView)
    rootStackView.addArrangedSubview(baseStackView)
    
    return rootStackView
  }
  
}




































