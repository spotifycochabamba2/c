//
//  WallCommentVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

public class WallCommentVC: UITableViewController {
  
  var wallOwnerId: String?
  var postId: String?
  var commenterId: String?
  
  @IBOutlet weak var usernameLabel: UILabel! {
    didSet {
      usernameLabel.text = ""
    }
  }
  
  @IBOutlet weak var profileImageView: UIImageViewCircular!
  @IBOutlet weak var upperView: UIView!
  @IBOutlet weak var commentButton: UIButton!
  @IBOutlet weak var commentTextView: UITextView!
  
  func tableViewTapped() {
    view.endEditing(true)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    
    tableView.addGestureRecognizer(tapGesture)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 40, height: 47), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    setNavHeaderTitle(title: "Create comment", color: UIColor.black)
    
    if let userId = commenterId {
      SVProgressHUD.show()
      
      User.getUser(
        byUserId: userId,
        completion: { (result) in
          
          DispatchQueue.main.async {
            SVProgressHUD.dismiss()
          }
          
          switch(result) {
          case .success(let user):
            DispatchQueue.main.async { [weak self] in
              self?.loadUser(user)
            }
          case .fail(let error):
            DispatchQueue.main.async { [weak self] in
              let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              self?.present(alert, animated: true)
            }
          }
      })
    }
    
    
    commentTextView.delegate = self
    commentTextView.text = Constants.Texts.writeComment
    commentTextView.textColor = .lightGray
  }
  
  func loadUser(_ user: User) {
    usernameLabel.text = user.username
    
    if let url = URL(string: user.profilePictureURL ?? "") {
      profileImageView.sd_setImage(with: url)
    }
  }
  
  @IBAction func commentButtonTouched() {
    commentButton.isEnabled = false
    commentButton.alpha = 0.5

    guard let postId = postId else {
      commentButton.isEnabled = true
      commentButton.alpha = 1.0
      
      let alert = UIAlertController(title: "Error", message: "Post Id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      present(alert, animated: true)
      return
    }
    
    guard let commenterId = commenterId else {
      commentButton.isEnabled = true
      commentButton.alpha = 1.0
      
      let alert = UIAlertController(title: "Error", message: "Commenter Id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      present(alert, animated: true)
      return
    }
    
    guard let wallOwnerId = wallOwnerId else {
      commentButton.isEnabled = true
      commentButton.alpha = 1.0
      
      let alert = UIAlertController(title: "Error", message: "Wall owner Id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      present(alert, animated: true)
      return
    }
    
    let text = commentTextView.text ?? ""
    
    SVProgressHUD.show()
    Comment.createComment(
      postId: postId,
      commenterId: commenterId,
      wallOwnerId: wallOwnerId,
      text: text,
      date: Date()) { [weak self] (error) in
        DispatchQueue.main.async { [weak self] in
          SVProgressHUD.dismiss()
          self?.commentButton.isEnabled = true
          self?.commentButton.alpha = 1.0
        }
        
        guard let this = self else { return }
        
        if let error = error {
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          this.present(alert, animated: true)
        } else {
          this.dismiss(animated: true)
        }
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  public func backButtonTouched() {
    dismiss(animated: true) { 
      
    }
  }
}

extension WallCommentVC {
  
  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      
      upperView.layoutIfNeeded()
      upperView.makeMeBordered(borderWidth: 1, cornerRadius: 3)
      
      upperView.layer.shadowColor = UIColor.lightGray.cgColor
      upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
      upperView.layer.shadowRadius = 3
      upperView.layer.shadowOpacity = 0.5
      
    } else if indexPath.row == 1 {
      commentButton.layoutIfNeeded()
      commentButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  
}

extension WallCommentVC: UITextViewDelegate {
  
  public func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == Constants.Texts.writeComment {
      textView.text = ""
      textView.textColor = .black
    }
    
    textView.becomeFirstResponder()
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
      textView.text = Constants.Texts.writeComment
      textView.textColor = .lightGray
    }
  }
  
}







































