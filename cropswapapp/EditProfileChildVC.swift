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
  
  var countryCellSelected = false
  var countryCellHeight: CGFloat = 66.0
  var countriesTableViewDelegate: CountryDelegate!
  var countrySelected: String?
  
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
  
  @IBOutlet weak var countryTableView: UITableView!
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var countryCell: UITableViewCell!
  @IBOutlet weak var countryTextField: UITextField!
  @IBOutlet weak var streetTextField: UITextField!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var stateTextField: UITextField!
  @IBOutlet weak var zipCodeTitleLabel: UILabel!
  @IBOutlet weak var zipCodeTextField: UITextField!
  @IBOutlet weak var switchShowAddress: UISwitch!
  
  @IBOutlet weak var aboutTextView: CSTextView!
  @IBOutlet weak var websiteTextField: UITextField!
//  @IBOutlet weak var locationTextView: UITextView!
  
  var profilePicture: UIImage?
  
  var country: String {
    get {
      return countryTextField.text ?? ""
    }
  }
  
  var about: String {
    get {
      return aboutTextView.text ?? ""
    }
  }
  
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
  
  var username: String {
    get {
      return usernameTextField.text ?? ""
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
  
  func getUsername() throws -> String {
    let username = usernameTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    
    if username.characters.count > 0 {
      return username
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.usernameNotProvided)
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.EditProfileChildToCamera {
      let vc = segue.destination as? CameraVC
      
      vc?.produceId = "none"
      vc?.photoNumber = .first
      vc?.pictureTaken = pictureTaken
    }
  }
  
  func didCountrySelect(_ country: String) {
    countryTextField.text = country
    countrySelected = country
    tryEnableZipCodeComponent()
    view.endEditing(true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    countriesTableViewDelegate = CountryDelegate(tableView: countryTableView)
    countriesTableViewDelegate.setup()
    countriesTableViewDelegate.didCountrySelect = didCountrySelect
    
    SVProgressHUD.show()
    User.getUser { [weak self] (result) in
      SVProgressHUD.dismiss()
      switch result {
      case .success(let user):
        DispatchQueue.main.async {
          self?.loadUserInfoToUI(user: user)
        }
      case .fail(let error):
        break
      }
    }
  }
  
  func tryEnableZipCodeComponent() {
    if (countrySelected ?? "") == Constants.Map.unitedStatesName {
      zipCodeTextField.text = ""
      zipCodeTextField.isEnabled = true
      zipCodeTextField.alpha = 1
      zipCodeTitleLabel.alpha = 1
    } else {
      zipCodeTextField.text = ""
      zipCodeTextField.isEnabled = false
      zipCodeTextField.alpha = 0.5
      zipCodeTitleLabel.alpha = 0.5
    }
  }
  
  func loadUserInfoToUI(user: User) {
    countryTextField.text = user.country
    countrySelected = user.country
    zipCodeTextField.text = user.zipCode
    
    tryEnableZipCodeComponent()
    
//    if (countrySelected ?? "") == Constants.Map.unitedStatesName {
//      zipCodeTextField.text = ""
//      zipCodeTextField.isEnabled = true
//      zipCodeTextField.alpha = 1
//      zipCodeTitleLabel.alpha = 1
//    } else {
//      zipCodeTextField.text = ""
//      zipCodeTextField.isEnabled = false
//      zipCodeTextField.alpha = 0.5
//      zipCodeTitleLabel.alpha = 0.5
//    }
    
    firstNameTextField.text = user.name
    lastNameTextField.text = user.lastName
    phoneNumberTextField.text = "\(user.phoneNumber ?? "")"
    websiteTextField.text = "\(user.website ?? "")"
    usernameTextField.text = user.username
//    locationTextView.text = "\(user.location ?? "")"
    emailAddressTextField.text = user.email
    streetTextField.text = user.street
    cityTextField.text = user.city
    stateTextField.text = user.state

    switchShowAddress.isOn = user.showAddress ?? false
    
    profileImageURL = user.profilePictureURL
    
    aboutTextView.text = user.about ?? ""
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    usernameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    firstNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    lastNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    phoneNumberTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    emailAddressTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    websiteTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    countryTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
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

extension EditProfileChildVC: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField === countryTextField {
      countryCellSelected = true
      
      tableView.beginUpdates()
      tableView.endUpdates()
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField === countryTextField {
      countryCellSelected = false
    }
    
    countryTextField.text = countrySelected
    
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField === countryTextField {
      let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
      
      countriesTableViewDelegate.filterCountries(byText: newString)
    }
    
    return true
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




extension EditProfileChildVC {
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = super.tableView(tableView, heightForRowAt: indexPath)
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if cell === countryCell {
      if countryCellSelected {
        return 200
      } else {
        return countryCellHeight
      }
    }
    
    return height
  }
  
}























