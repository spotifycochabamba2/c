//
//  ProfileChildVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileChildVC: UITableViewController {
  
  
  @IBOutlet weak var signinInstagramButton: UIButton!
  @IBOutlet weak var siginInstagramShadowView: UIView!
  
  @IBOutlet weak var instagramCollectionView: UICollectionView!
  
  var instagramURLStrings = [(String, String)]()
  
  var currentUserId: String?
  var currentUsername: String?
  var showBackButton = false
  
  @IBOutlet weak var instagramCell: UITableViewCell!
  @IBOutlet weak var aboutCell: UITableViewCell!
  @IBOutlet weak var streetCell: UITableViewCell!
  @IBOutlet weak var cityCell: UITableViewCell!
  @IBOutlet weak var stateCell: UITableViewCell!
  @IBOutlet weak var zipCodeCell: UITableViewCell!
  @IBOutlet weak var showAddressCell: UITableViewCell!    
  @IBOutlet weak var emailAddressCell: UITableViewCell!
  @IBOutlet weak var phoneNumberCell: UITableViewCell!
  
  
  @IBOutlet weak var countryLabel: UILabel! {
    didSet {
      countryLabel.text = ""
    }
  }
  
  @IBOutlet weak var aboutLabel: UILabel! {
    didSet {
      aboutLabel.text = ""
    }
  }
  
  @IBOutlet weak var nameLabel: UILabel! {
    didSet {
      nameLabel.text = ""
    }
  }
  
  @IBOutlet weak var phoneNumberLabel: UILabel! {
    didSet {
      phoneNumberLabel.text = ""
    }
  }
  
  @IBOutlet weak var emailLabel: UILabel! {
    didSet {
      emailLabel.text = ""
    }
  }
  
  @IBOutlet weak var websiteLabel: UILabel! {
    didSet {
      websiteLabel.text = ""
    }
  }
  
  @IBOutlet weak var streetLabel: UILabel! {
    didSet {
      streetLabel.text = ""
    }
  }
  
  @IBOutlet weak var cityLabel: UILabel! {
    didSet {
      cityLabel.text = ""
    }
  }
  
  @IBOutlet weak var stateLabel: UILabel! {
    didSet {
      stateLabel.text = ""
    }
  }
  
  @IBOutlet weak var zipCodeLabel: UILabel! {
    didSet {
      zipCodeLabel.text = ""
    }
  }
  
  @IBOutlet weak var usernameLabel: UILabel! {
    didSet {
      usernameLabel.text = ""
    }
  }
  
  @IBOutlet weak var showAddressSwitch: UISwitch!
  
  @IBOutlet weak var profileImageView: UIImageView!{
    didSet {
      profileImageView.contentMode = .center
      profileImageView.backgroundColor = UIColor.hexStringToUIColor(hex: "#e1e3e5")
      profileImageView.image = UIImage(named: "cropswap-gray-logo")
    }
  }
  
  var profileImageURL: String? {
    didSet {
      
      if let url = URL(string: profileImageURL ?? "") {
        profileImageView.contentMode = .scaleAspectFit
        
        profileImageView.sd_setImage(with: url)
      }
      
    }
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if instagramCell == cell {
      signinInstagramButton.layoutIfNeeded()
      
      siginInstagramShadowView.layoutIfNeeded()
      siginInstagramShadowView.makeMeBordered()
      
      siginInstagramShadowView.layer.shadowColor = UIColor.lightGray.cgColor
      siginInstagramShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
      siginInstagramShadowView.layer.shadowRadius = 3
      siginInstagramShadowView.layer.shadowOpacity = 0.5
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = super.tableView(tableView, heightForRowAt: indexPath)
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if showBackButton {
      if cell === streetCell {
        return 0
      } else if cell === cityCell {
        return 0
      } else if cell === stateCell {
        return 0
      } else if cell === zipCodeCell {
        return 0
      } else if cell === showAddressCell {
        return 0
      } else if cell == phoneNumberCell {
        return 0
      } else if cell == emailAddressCell {
        return 0
      }
    }
  
    if cell === aboutCell {
      return UITableViewAutomaticDimension
    }
    
    if cell === instagramCell {
      if instagramURLStrings.count > 0 {
        let screenWidth = UIScreen.main.bounds.width
        print(screenWidth)
        let circleWidth: CGFloat = 60.0
        let circleHeight: CGFloat = 60.0
        let numCircles = screenWidth / circleWidth
        print(numCircles)
        let heightCircles = ceil(CGFloat(instagramURLStrings.count) / numCircles)
        print(heightCircles)
        
        let totalHeight = heightCircles * circleHeight
        let heightCirclesSpacing = 10 * (totalHeight / circleHeight)
        print(heightCirclesSpacing)
        
        return totalHeight + heightCirclesSpacing
      } else {
        
        return UITableViewAutomaticDimension
      }      
    }
    
    return height
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    signinInstagramButton.isHidden = true
    siginInstagramShadowView.isHidden = true
    instagramCollectionView.isHidden = true
    
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension
    
    if showBackButton {
      setNavHeaderTitle(title: "\(currentUsername ?? "User")'s Profile", color: UIColor.black)
      
      let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
      leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    }
  }
  
  func backButtonTouched() {
    dismiss(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.ProfileChildToInstagramLogin {
      let nc = segue.destination as? UINavigationController
      let vc = nc?.viewControllers.first as? InstagramVC
      
      vc?.onlyForGettingPictures = true
      vc?.loggedSuccessfully = loggedSuccesfully
    } else if segue.identifier == Storyboard.ProfileChildToPhotoViewer {
      let vc = segue.destination as? PhotoViewerVC
      vc?.isImagesURLStrings = true
      vc?.imagesURLStrings = instagramURLStrings.map { return $0.1 }
    }
  }
  
  func loggedSuccesfully(user: User) {
    print(user)
  }
  
  @IBAction func signinInstagramButtonTouched() {
    performSegue(withIdentifier: Storyboard.ProfileChildToInstagramLogin, sender: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#f9f9f9")
    
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }
    
    User.getUser(byUserId: currentUserId) { [weak self] (result) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      
      switch result {
      case .success(let user):
        DispatchQueue.main.async {
          self?.loadUserInfoToUI(user: user)
        }
      case .fail(let error):
        print(error)
        break
      }
    }
  }
  
  
  func loadUserInfoToUI(user: User) {
    
    setNavHeaderTitle(title: "\(user.name)'s Profile", color: UIColor.black)
    
    if let instagramToken = user.instagramToken,
       let instagramId = user.instagramId
    {
      signinInstagramButton.isHidden = true
      siginInstagramShadowView.isHidden = true
      instagramCollectionView.isHidden = false
      
      Produce.getRecentTenInstagramPictures(
        instagramClientId: instagramId,
        instagramAccessToken: instagramToken,
//        instagramClientId: "2286383822",
//        instagramAccessToken: "1631861081.3a81a9f.9d7b2e2bc94f42df935055677efb2c4d",
        completion: { [weak self] (result) in
          switch result {
          case .success(let images):
            self?.instagramURLStrings = images
            
            DispatchQueue.main.async {
              self?.updateInstagramPicturesOnUI {
                DispatchQueue.main.async {
//                  self?.tableView.beginUpdates()
//                  let indexPath = IndexPath(row: 4, section: 0)
//                  self?.tableView.reloadRows(at: [indexPath], with: .automatic)
//                  self?.tableView.endUpdates()
//                  
                  self?.tableView.reloadData()
                }
              }
            }
          case .fail(let error):
            print(error)
          }
      })
    } else {
      
      if let currentUserId = User.currentUser?.uid,
         let userId = user.id,
         userId != currentUserId
      {
        signinInstagramButton.isHidden = true
        siginInstagramShadowView.isHidden = true
      } else {
        signinInstagramButton.isHidden = false
        siginInstagramShadowView.isHidden = false
      }
      
      instagramCollectionView.isHidden = true
    }
    
    
    nameLabel.text = "\(user.name) \(user.lastName ?? "")"
    phoneNumberLabel.text = "\(user.phoneNumber ?? "")"
    websiteLabel.text = "\(user.website ?? "")"

    usernameLabel.text = user.username
    emailLabel.text = user.email
    
    profileImageURL = user.profilePictureURL
    
    streetLabel.text = user.street
    cityLabel.text = user.city
    stateLabel.text = user.state
    zipCodeLabel.text = user.zipCode
    countryLabel.text = user.country
    
    showAddressSwitch.isOn = user.showAddress ?? false
    aboutLabel.text = user.about
    
    tableView.reloadData()
  }
  
  func updateInstagramPicturesOnUI(completion: @escaping () -> Void) {
    instagramCollectionView.layoutIfNeeded()
    instagramCollectionView.layoutSubviews()
    
    instagramCollectionView.reloadData()
    instagramCollectionView.performBatchUpdates({
      
      }, completion: { (finished) in
        if finished {
          completion()
        }
    })
  }
}

extension ProfileChildVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    ProfileChildToPhotoViewer
    performSegue(withIdentifier: Storyboard.ProfileChildToPhotoViewer, sender: indexPath.row)
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return instagramURLStrings.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 60, height: 60)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileInstagramCell.identifierId, for: indexPath) as! ProfileInstagramCell
    let instagramURLString = instagramURLStrings[indexPath.row]
    
    cell.instagramURLString = instagramURLString.0
    
    return cell
  }
}







































