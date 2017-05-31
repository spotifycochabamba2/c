//
//  EditProfile.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class EditProfileContainerVC: UIViewController {
  
  var editProfileChildVC: EditProfileChildVC?
  
  @IBOutlet weak var updateButton: UIButton! {
    didSet {
      updateButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  @IBOutlet weak var updateView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isTranslucent = false
    
    setNavHeaderTitle(title: "Edit Profile", color: UIColor.black)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    updateView.layer.shadowOffset = CGSize(width: 0, height: 0);
    updateView.layer.shadowRadius = 2;
    updateView.layer.shadowColor = UIColor.black.cgColor
    updateView.layer.shadowOpacity = 0.3;
  }
  
  func backButtonTouched() {
    dismiss(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    editProfileChildVC = segue.destination as? EditProfileChildVC
  }
  
  @IBAction func updateButtonTouched() {
    guard let editProfileChildVC = editProfileChildVC else {
      return
    }
    
    let image = editProfileChildVC.profilePicture
    var imageData: Data?
    
    if let image = image {
      imageData = UIImageJPEGRepresentation(image, 0.2)
    }
    
    guard let userId = User.currentUser?.uid else {
      let alert = UIAlertController(title: "Error", message: "User id not found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      present(alert, animated: true)
      return
    }
    
    SVProgressHUD.show()
    
    Ax.serial(tasks: [
      { done in
        let street = editProfileChildVC.street
        let city = editProfileChildVC.city
        let state = editProfileChildVC.state
        let zipCode = editProfileChildVC.zipCode
        let showAddress = editProfileChildVC.showAddress
        
        User.saveLocation(
          byUserId: userId,
          street: street,
          city: city,
          state: state,
          zipCode: zipCode,
          showAddress: showAddress,
          completion: { (error) in
            done(error)
        })
      },
      
      { done in
        do {
          let firstName = try editProfileChildVC.getFirstName()
          let lastName = editProfileChildVC.lastName
          let phoneNumber = editProfileChildVC.phoneNumber
          let website = editProfileChildVC.website
          let location = ""
          let about = editProfileChildVC.about
          
          User.updateUser(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            website: website,
            location: location,
            about: about,
            completion: { (error) in
              done(error)
          })

        } catch ValidationFormError.error(let errorMessage) {
          let error = NSError(domain: "EditProfile", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
          done(error)
        } catch {
          done(error as NSError?)
        }
      },
      
      { done in
        if let imageData = imageData {
          User.updateUserPicture(
            pictureData: imageData,
            userId: userId) { (result) in
              
              
              switch result {
              case .fail(let error):
                done(error)
              case .success(let pictureURL):
                print(pictureURL)
                done(nil)
              }
          }
        } else {
          done(nil)
        }
      },
    ]) { [weak self] (error) in
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      
      if let error = error {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
          self?.present(alert, animated: true)
        }
      } else {
        DispatchQueue.main.async {
          self?.dismiss(animated: true)
        }
      }
    }
  }
  
}















































