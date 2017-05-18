//
//  EditProfileChildVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/3/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditProfileChildVC: UITableViewController {
  
  @IBOutlet weak var profileImageView: UIImageView! {
    didSet {
      profileImageView.contentMode = .center
      profileImageView.backgroundColor = UIColor.hexStringToUIColor(hex: "#e1e3e5")
      profileImageView.image = UIImage(named: "cropswap-gray-logo")
    }
  }
  
  @IBOutlet weak var shadowOfSelectInMapButton: UIView!
  @IBOutlet weak var selectInMapButton: UIButton!
  
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var phoneNumberTextField: UITextField!
  @IBOutlet weak var emailAddressTextField: UITextField!
  
  @IBOutlet weak var streetTextField: UITextField!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var stateTextField: UITextField!
  @IBOutlet weak var zipCodeTextField: UITextField!
  @IBOutlet weak var switchShowAddress: UISwitch!
  
  @IBOutlet weak var websiteTextField: UITextField!
//  @IBOutlet weak var locationTextView: UITextView!
  
  var profilePicture: UIImage?
  
  var lastName: String {
    get {
      return lastNameTextField.text ?? ""
    }
  }
  
  var phoneNumber: String {
    get {
      return phoneNumberTextField.text ?? ""
    }
  }
  
  var website: String {
    get {
      return websiteTextField.text ?? ""
    }
  }
  
  var street: String {
    get {
      return streetTextField.text ?? ""
    }
  }
  
  var city: String {
    get {
      return cityTextField.text ?? ""
    }
  }
  
  var state: String {
    get {
      return stateTextField.text ?? ""
    }
  }
  
  var zipCode: String {
    get {
      return zipCodeTextField.text ?? ""
    }
  }
  
  var showAddress: Bool {
    get {
      return switchShowAddress.isOn
    }
  }
  
//  var location: String {
//    get {
//      return locationTextView.text
//    }
//  }
  
  func getFirstName() throws -> String {
    let firstName = firstNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    
    if firstName.characters.count > 0 {
      return firstName
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.firstNameNotProvided)
    }
  }
  
  
  var profileImageURL: String? {
    didSet {
      print(profileImageURL)
      if let url = URL(string: profileImageURL ?? "") {
        profileImageView.contentMode = .scaleAspectFit
        
        print(url)
        profileImageView.sd_setImage(with: url)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.EditProfileChildToCamera {
      let vc = segue.destination as? CameraVC
      
      vc?.produceId = "none"
      vc?.photoNumber = .first
      vc?.pictureTaken = pictureTaken
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    SVProgressHUD.show()
    
    User.getUser { [weak self] (result) in
      SVProgressHUD.dismiss()
      switch result {
      case .success(let user):
        self?.loadUserInfoToUI(user: user)
      case .fail(let error):
        print(error)
        break
      }
    }
    
//    locationTextView.textContainer.maximumNumberOfLines = 2
//    locationTextView.delegate = self
  }
  
  func loadUserInfoToUI(user: User) {
    firstNameTextField.text = user.name
    lastNameTextField.text = user.lastName
    phoneNumberTextField.text = "\(user.phoneNumber ?? "")"
    websiteTextField.text = "\(user.website ?? "")"
//    locationTextView.text = "\(user.location ?? "")"
    emailAddressTextField.text = user.email
    
    streetTextField.text = user.street
    cityTextField.text = user.city
    stateTextField.text = user.state
    zipCodeTextField.text = user.zipCode
    switchShowAddress.isOn = user.showAddress ?? false
    
    profileImageURL = user.profilePictureURL
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    firstNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    lastNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    phoneNumberTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    emailAddressTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    websiteTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    streetTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    cityTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    stateTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    zipCodeTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
    
//    locationTextView.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
  }
  
  func pictureTaken(image: UIImage, _: ProducePhotoNumber) {
    profilePicture = image
    
    DispatchQueue.main.async { [weak self] in
      self?.profileImageView.image = image
      self?.profileImageView.contentMode = .scaleAspectFit
    }
  }
  
  @IBAction func pickPictureButtonTouched() {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let imagePicker = UIImagePickerController()
      
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      
      present(imagePicker, animated: true, completion: nil)
    }
  }
  
  @IBAction func takePictureButtonTouched() {
    performSegue(withIdentifier: Storyboard.EditProfileChildToCamera, sender: nil)
  }
  
  
  @IBAction func selectInMapButtonTouched() {
    
  }
  
}

extension EditProfileChildVC {
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    if indexPath.row == 5 {
//      selectInMapButton.layoutIfNeeded()
//      
//      shadowOfSelectInMapButton.layoutIfNeeded()
//      shadowOfSelectInMapButton.makeMeBordered()
//      
//      shadowOfSelectInMapButton.layer.shadowColor = UIColor.lightGray.cgColor
//      shadowOfSelectInMapButton.layer.shadowOffset = CGSize(width: 0, height: 0)
//      shadowOfSelectInMapButton.layer.shadowRadius = 3
//      shadowOfSelectInMapButton.layer.shadowOpacity = 0.5
//    }
  }
}

extension EditProfileChildVC: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
    let newLines = text.components(separatedBy: CharacterSet.newlines)
    let linesAfterChange = existingLines.count + newLines.count - 1
    return linesAfterChange <= textView.textContainer.maximumNumberOfLines
  }
}


extension EditProfileChildVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    let deviceSize = UIScreen.main.bounds.size
    let resizedImage = chosenImage.resizeImage(withTargerSize: deviceSize)
    
    pictureTaken(image: resizedImage, .first)
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}























