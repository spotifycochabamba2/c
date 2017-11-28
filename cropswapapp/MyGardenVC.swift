//
//  MyGardenVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class MyGardenVC: UICollectionViewController {
  
  var currentUser: User?
  
  let headerIdentifier = "MyGardenHeaderCell"
  let cellIdentifier = "MyGardenCell"
  
  var produces = Array<[String: Any]>() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.collectionView?.reloadData()
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    var userId: String?
    
    SVProgressHUD.show()
    Ax.serial(tasks: [
      
      { [weak self] done in
        
        if self?.currentUser == nil {
          User.getUser { (result) in
            switch result {
            case .success(let userFound):
              self?.currentUser = userFound
              userId = userFound.id
              
              let indexSet = IndexSet(integer: 0)
              
              DispatchQueue.main.async {
                self?.collectionView?.reloadSections(indexSet)
              }
              
              done(nil)
            case .fail(let error):
              done(error)
            }
          }
        } else {
          userId = self?.currentUser!.id!
          done(nil)
        }
        
      },
      
      { [weak self] done in
        self?.getProduces(byUserId: userId!) {
          done(nil)
        }
      }
      
      ], result: { [weak self] (error) in
        SVProgressHUD.dismiss()
        if let error = error {
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          
          DispatchQueue.main.async {
            self?.present(alert, animated: true)
          }
        }
      })
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    setNavBarButtons()
    navigationBarIsHidden = false
    
    view.backgroundColor = UIColor(patternImage: UIImage(named: "mygarden-background")!)
    
    collectionView?.backgroundColor = .clear
    collectionView?.backgroundView = UIView(frame: CGRect.zero)
  }
  
  func setNavBarButtons() {
    setNavBarColor(color: .cropswapYellow)
    setNavHeaderTitle(title: "My Garden")
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon", size: CGSize(width: 24, height: 25), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(leftButtonIconTouched), for: .touchUpInside)
    
    let rightButtonIcon = setNavIcon(imageName: "mygarden-settings-icon", size: CGSize(width: 28, height: 28), position: .right)
    rightButtonIcon.addTarget(self, action: #selector(rightButtonIconTouched), for: .touchUpInside)
    
  }
  
  func rightButtonIconTouched() {
    
  }
  
  func leftButtonIconTouched() {
    _ = navigationController?.popViewController(animated: true)
  }
  
  func openCameraVC() {
    performSegue(withIdentifier: Storyboard.MyGardenToCamera, sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.MyGardenToCamera {
      let vc = segue.destination as? CameraVC
      
      vc?.produceId = "none"
      vc?.photoNumber = .first
      vc?.pictureTaken = pictureTaken
    } else if segue.identifier == Storyboard.MyGardenToAddProduce {
      let selectedProduceIndex = (collectionView?.indexPathsForSelectedItems?.first?.row ?? 0) - 1
      var produceSelectedId: String?
      
      if selectedProduceIndex >= 0 {
        produceSelectedId = produces[selectedProduceIndex]["id"] as? String
      }
      
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? AddProduceVC
      vc?.currentState = sender as? AddProduceVCState
      vc?.currentProduceId = produceSelectedId
    }
  }
  
  func getProduces(byUserId userId: String, completion: (() -> Void)? = nil) {
    
    User.getProducesByUser(byUserId: userId) { [weak self] produces in
      self?.produces = produces
      
      
      completion?()
    }
    
  }
  
  func pictureTaken(image: UIImage, _: ProducePhotoNumber) {
    
    guard let imageData = UIImageJPEGRepresentation(image, 0.2) else {
      let alert = UIAlertController(title: "Error", message: "Image provided not valid", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    guard let userId = User.currentUser?.uid else {
      let alert = UIAlertController(title: "Error", message: "User id not valid", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    SVProgressHUD.show()
    User.updateUserPicture(
      pictureData: imageData,
      userId: userId) { [weak self] (result) in
        SVProgressHUD.dismiss()
        
        switch result {
        case .fail(let error):
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          DispatchQueue.main.async {
            self?.present(alert, animated: true)
          }

        case .success(let pictureURL):
          self?.currentUser?.profilePictureURL = pictureURL
          let indexSet = IndexSet(integer: 0)
          
          DispatchQueue.main.async {
            self?.collectionView?.reloadSections(indexSet)
          }
        }
    }
  }
}

extension MyGardenVC: UICollectionViewDelegateFlowLayout {
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return produces.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    let cellWidth = (collectionView.frame.size.width / 2)
    let leftInset = collectionView.center.x - (cellWidth / 2)

    if (produces.count + 1) == 1 {
      return UIEdgeInsetsMake(0, leftInset, 0, leftInset)
    } else {
      return UIEdgeInsetsMake(0, 7, 0, 7)
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    var addProduceVCType: AddProduceVCState!
    
    if indexPath.row == 0 {
      addProduceVCType = AddProduceVCState.add
    } else {
      addProduceVCType = AddProduceVCState.read
    }
    
    performSegue(withIdentifier: Storyboard.MyGardenToAddProduce, sender: addProduceVCType)
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MyGardenCell
    
    if indexPath.row == 0 {
      cell.type = MyGardenCellType.addItem
    } else {
      let produce = produces[indexPath.row - 1]
      cell.type = MyGardenCellType.produce
      if
        let imageURL = produce["firstPictureURL"] as? String,
        let produceType = produce["produceType"] as? String,
        let quantity = produce["quantity"] as? Int,
        let quantityType = produce["quantityType"] as? String
      {
        cell.imageURL = imageURL
        cell.produceName = produceType
        cell.quantity = "\(quantityType) \(quantity)"
      }

    }

    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.frame.size.width/2) - 10, height: collectionView.frame.size.width/2 + 20);
//    return CGSize(width: (collectionView.frame.size.width/2), height: collectionView.frame.size.width/2 + 20);
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! MyGardenHeaderCell
    
    headerView.openCameraVC = openCameraVC
    
    if let username = currentUser?.name {
      headerView.username = username
    }
    
    if let profilePictureURL = currentUser?.profilePictureURL {
      headerView.userProfileImageURL = profilePictureURL
    }
    
    return headerView
  }
}






































