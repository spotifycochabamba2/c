//
//  WallPostVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

public class WallPostVC: UITableViewController {
  
  var currentUserId: String?
  var wallOwnerId: String?
  var attachedImage: UIImage?
  
  @IBOutlet weak var usernameLabel: UILabel! {
    didSet {
      usernameLabel.text = "Loading..."
    }
  }
  
  @IBOutlet weak var attachedPhotoStackView: UIStackView!
  
  @IBOutlet weak var profileImageView: UIImageViewCircular!
  
  @IBOutlet weak var photoOptionsView: UIView!
  
  @IBOutlet weak var upperView: UIView!
  @IBOutlet weak var postButton: UIButton!
  @IBOutlet weak var postTextView: UITextView!
  
  var showPhotoOptionsView = false {
    didSet {
      if showPhotoOptionsView {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
          self?.photoOptionsView.alpha = 1
          })
      } else {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
          self?.photoOptionsView.alpha = 0
          })
      }
    }
  }
  
  @IBAction func takePhotoButtonTouched() {
    view.endEditing(true)
    showCameraView()
  }
  
  @IBAction func uploadPhotoButtonTouched() {
    view.endEditing(true)
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let imagePicker = UIImagePickerController()
      
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      
      present(imagePicker, animated: true)
    }
  }
  
  public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    showPhotoOptionsView = false
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    photoOptionsView.makeMeBordered(cornerRadius: 4.0)
    
    photoOptionsView.layer.shadowColor = UIColor.lightGray.cgColor
    photoOptionsView.layer.shadowOffset = CGSize(width: 0, height: 0)
    photoOptionsView.layer.shadowRadius = 3
    photoOptionsView.layer.shadowOpacity = 0.5
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    photoOptionsView.alpha = 0
    
    attachedPhotoStackView.isHidden = true
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    
    tableView.addGestureRecognizer(tapGesture)
    
    if let userId = currentUserId {
      SVProgressHUD.show()
      User.getUser(byUserId: userId, completion: { (result) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        switch result {
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
    
    postTextView.delegate = self
    postTextView.text = Constants.Texts.writePost
    postTextView.textColor = .lightGray
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 40, height: 47), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    setNavHeaderTitle(title: "Create post", color: UIColor.black)
  }
  
  func pictureTaken(image: UIImage, number: ProducePhotoNumber) {
    attachedImage = image
    DispatchQueue.main.async { [weak self] in
      self?.showPhotoOptionsView = false
      self?.attachedPhotoStackView.isHidden = false
    }
    
    print(image)
  }
  
  func cameraCancelled() {
    DispatchQueue.main.async { [weak self] in
      self?.showPhotoOptionsView = false
    }
  }
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.WallPostToCamera {
      let vc = segue.destination as? CameraVC
      
      vc?.pictureTaken = pictureTaken
      vc?.cancelled = cameraCancelled
      vc?.photoNumber = ProducePhotoNumber.first
    } else if segue.identifier == Storyboard.WallPostToViewPhoto {
      let vc = segue.destination as? ProduceImageZoomableVC
      vc?.customImage = attachedImage
      vc?.hideCloseButton = false
    }
  }
  
  func tableViewTapped() {
    view.endEditing(true)
    showPhotoOptionsView = false
  }
  
  func loadUser(_ user: User) {
    usernameLabel.text = user.username
    
    if let url = URL(string: user.profilePictureURL ?? "") {
      profileImageView.sd_setImage(with: url)
    }
  }
  
  @IBAction func showAttachedImageButtonTapped() {
    view.endEditing(true)
    performSegue(withIdentifier: Storyboard.WallPostToViewPhoto, sender: nil)
  }
  
  @IBAction func removeAttachedImageButtonTapped() {
    attachedPhotoStackView.isHidden = true
    attachedImage = nil
  }
  
  @IBAction func addPhotoButtonTapped() {
    view.endEditing(true)
    showPhotoOptionsView = !showPhotoOptionsView
  }
  
  @IBAction func addPhotoImageTapped() {
    view.endEditing(true)
    showPhotoOptionsView = !showPhotoOptionsView
  }
  
  
  func showCameraView() {
    performSegue(withIdentifier: Storyboard.WallPostToCamera, sender: nil)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  public func backButtonTouched() {
    dismiss(animated: true) {
      
    }
  }
  
  @IBAction func postButtonTouched() {
    postButton.isEnabled = false
    postButton.alpha = 0.5
    
    guard let wallOwnerId = wallOwnerId else {
      postButton.isEnabled = true
      postButton.alpha = 1.0
      
      let alert = UIAlertController(title: "Error", message: "Wall owner id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      return
    }
    
    guard let posterId = User.currentUser?.uid else {
      postButton.isEnabled = true
      postButton.alpha = 1.0
      
      let alert = UIAlertController(title: "Error", message: "Poster id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      return
    }
    
    let text = postTextView.text ?? ""
    
    SVProgressHUD.show()
    
    Post.createPost(
      byPosterId: posterId,
      wallOwnerId: wallOwnerId,
      text: text,
      attachedImage: attachedImage,
      date: Date()) { [weak self] (error) in
        DispatchQueue.main.async { [weak self] in
          SVProgressHUD.dismiss()
          self?.postButton.isEnabled = true
          self?.postButton.alpha = 1.0
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
}


extension WallPostVC {
  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      upperView.layoutIfNeeded()
      upperView.makeMeBordered(borderWidth: 1, cornerRadius: 3)
      
      upperView.layer.shadowColor = UIColor.lightGray.cgColor
      upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
      upperView.layer.shadowRadius = 3
      upperView.layer.shadowOpacity = 0.5
    } else if indexPath.row == 1 {
      postButton.layoutIfNeeded()
      
      postButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  

  
}



extension WallPostVC: UITextViewDelegate {
  public func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == Constants.Texts.writePost {
      textView.text = ""
      textView.textColor = .black
    }
    showPhotoOptionsView = false
    textView.becomeFirstResponder()
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
      textView.text = Constants.Texts.writePost
      textView.textColor = .lightGray
    }
  }
}


extension WallPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      let deviceSize = UIScreen.main.bounds.size
      let resizedImage = chosenImage.resizeImage(withTargerSize: deviceSize)
      
      self.attachedImage = resizedImage
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.dismiss(animated: true)
      self?.showPhotoOptionsView = false
      self?.attachedPhotoStackView.isHidden = false
    }
  }
  
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    DispatchQueue.main.async { [weak self] in
      self?.showPhotoOptionsView = false
      self?.dismiss(animated: true)
    }
  }
}






































