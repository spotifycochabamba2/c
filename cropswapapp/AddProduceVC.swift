//
//  AddProduceVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/23/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import Ax
import SVProgressHUD

// add: when user creates a produce
// read: when user is only seeing the produce
// edit: when user is editing the produce
enum AddProduceVCState {
  case add, read, edit
}

enum ValidationFormError: Error {
  case error(String)
}

class AddProduceVC: UIViewController {
  
  var currentUser: User?
  var currentProduceId: String?
  var currentProduce: Produce? {
    didSet {
      loadProduceToUI()
    }
  }
  
  @IBOutlet weak var viewTopLayoutConstraint: NSLayoutConstraint!
  @IBOutlet weak var produceTypesTableViewHeightConstraint: NSLayoutConstraint! {
    didSet {
      produceTypesTableViewHeightConstraint.constant = 0
    }
  }
  var produceTypesDelegate: ProduceTypesDelegate!
  
  @IBOutlet weak var produceTypeTableView: UITableView!
  
  var produceTypeTableViewIsHidden = false {
    didSet {
      if produceTypeTableViewIsHidden {
        produceTypesTableViewHeightConstraint.constant = 0
      } else {
        produceTypesTableViewHeightConstraint.constant = 128
      }
      
      UIView.animate(
        withDuration: 0.4,
        delay: 0.4,
        usingSpringWithDamping: 0.5,
        initialSpringVelocity: 0.5,
        options: [],
        animations: { [weak self] in
          self?.view.layoutIfNeeded()
        })
    }
  }
  
  var firstPhotoEdited = false
  var secondPhotoEdited = false
  var thirdPhotoEdited = false
  var fourthPhotoEdited = false
  var fifthPhotoEdited = false
  
  
  var firstPhotoSaved = false {
    didSet {
      
    }
  }
  
  var secondPhotoSaved = false {
    didSet {
      
    }
  }
  
  var thirdPhotoSaved = false {
    didSet {
      
    }
  }
  
  var fourthPhotoSaved = false {
    didSet {
      
    }
  }
  
  var fifthPhotoSaved = false {
    didSet {
      
    }
  }

  var backLeftButton: UIButton!
  var cancelLeftButton: UIButton!
  
  var editRightButton: UIButton!
  var deleteRightButton: UIButton!
  var doneRightButton: UIButton!
  var saveRightButton: UIButton!
  
  let backLeftButtonWidth: CGFloat = 24.0
  let cancelLeftButtonWidth: CGFloat = 42.0
  
  let editRightButtonWidth: CGFloat = 31.0
  let deleteRightButtonWidth: CGFloat = 50.0
  let doneRightButtonWidth: CGFloat = 35.0
  let saveRightButtonWidth: CGFloat = 41.0
  
  @IBOutlet weak var cameraButton: UIButton!
  
  @IBOutlet weak var onePictureButton: UIButton! {
    didSet {
      onePictureButton.imageView?.contentMode = .scaleAspectFit
    }
  }
  
  @IBOutlet weak var twoPictureButton: UIButton! {
    didSet {
      twoPictureButton.imageView?.contentMode = .scaleAspectFit
    }
  }

  @IBOutlet weak var threePictureButton: UIButton! {
    didSet {
      threePictureButton.imageView?.contentMode = .scaleAspectFit
    }
  }

  @IBOutlet weak var fourPictureButton: UIButton! {
    didSet {
      fourPictureButton.imageView?.contentMode = .scaleAspectFit
    }
  }

  @IBOutlet weak var fivePictureButton: UIButton! {
    didSet {
      fivePictureButton.imageView?.contentMode = .scaleAspectFit
    }
  }

  
  @IBOutlet weak var produceTypeTextField: UITextField!
  @IBOutlet weak var specificTypeTextField: UITextField!
  
  @IBOutlet weak var quantityLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  @IBOutlet weak var plantStartButton: UIButton!
  @IBOutlet weak var seedStartButton: UIButton!
  @IBOutlet weak var organicButton: UIButton!
  @IBOutlet weak var compostTeaButton: UIButton!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var quantityTypeLabel: UILabel!
  
  var numberFormatter = NumberFormatter()
  
  var quantityType = "" {
    didSet {
      quantityTypeLabel.text = quantityType
    }
  }
  
  var quantity = 0 {
    didSet {
      if quantity >= 0 {
        quantityLabel.text = "\(quantity)"
      } else {
        quantity = 0
      }
    }
  }
  
  var price: Double = 0 {
    didSet {
      if price >= 0 {
        priceLabel.text = numberFormatter.string(from: NSNumber(value: price))
      } else {
        price = 0
      }
    }
  }
  
  @IBAction func addPriceButtonTouched() {
    price += 0.5
  }
  
  @IBAction func substractPriceButtonTouched() {
    price -= 0.5
  }
  
  @IBAction func addQuantityButtonTouched() {
    quantity += 1
  }
  
  @IBAction func substractQuantityButtonTouched() {
    quantity -= 1
  }
  
  
  var plantStartSelected = false {
    didSet {
      if plantStartSelected {
        plantStartButton.setImage(UIImage(named: "addproduce-selection-on-icon"), for: .normal)
      } else {
        plantStartButton.setImage(UIImage(named: "addproduce-selection-off-icon"), for: .normal)
      }
    }
  }
  
  var seedStartSelected = false {
    didSet {
      if seedStartSelected {
        seedStartButton.setImage(UIImage(named: "addproduce-selection-on-icon"), for: .normal)
      } else {
        seedStartButton.setImage(UIImage(named: "addproduce-selection-off-icon"), for: .normal)
      }
    }
  }
  
  var organicSelected = false {
    didSet {
      if organicSelected {
        organicButton.setImage(UIImage(named: "addproduce-selection-on-icon"), for: .normal)
      } else {
        organicButton.setImage(UIImage(named: "addproduce-selection-off-icon"), for: .normal)
      }
    }
  }
  
  var compostTeaSelected = false {
    didSet {
      if compostTeaSelected {
        compostTeaButton.setImage(UIImage(named: "addproduce-selection-on-icon"), for: .normal)
      } else {
        compostTeaButton.setImage(UIImage(named: "addproduce-selection-off-icon"), for: .normal)
      }
    }
  }
  
  @IBOutlet weak var upQuantityButton: UIButton!
  @IBOutlet weak var downQuantityButton: UIButton!
  
  @IBOutlet weak var upPriceButton: UIButton!
  @IBOutlet weak var downPriceButton: UIButton!
  
  @IBOutlet weak var descriptionPlaceHolderLabel: UILabel!
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  var currentState: AddProduceVCState?
  
  var state: AddProduceVCState! {
    didSet {
      if let state = state {
        navigationItem.leftBarButtonItems?.removeAll()
        navigationItem.rightBarButtonItems?.removeAll()
      
        switch state {
        case .add:
          currentState = .add
          print("add")
          form(enable: true)
          print(navigationItem)
          print(navigationItem.leftBarButtonItems)
          navigationItem.leftBarButtonItems?.append(UIBarButtonItem(customView:backLeftButton))
          navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView:saveRightButton))
        case .edit:
          currentState = .edit
          form(enable: true)
          produceTypeTextField.becomeFirstResponder()
          navigationItem.leftBarButtonItems?.append(UIBarButtonItem(customView:cancelLeftButton))
          navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView:doneRightButton))
          break
        case .read:
          print("read")
          currentState = .read
          form(enable: false)
          navigationItem.leftBarButtonItems?.append(UIBarButtonItem(customView:backLeftButton))
          navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView:editRightButton))
          navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView:deleteRightButton))
        }
      }
    }
  }
  
  @IBAction func cameraButtonTouched() {
    var currentPhotoNumber: ProducePhotoNumber?
    
    if !firstPhotoSaved {
      currentPhotoNumber = ProducePhotoNumber.first
    } else if !secondPhotoSaved {
      currentPhotoNumber = ProducePhotoNumber.second
    } else if !thirdPhotoSaved {
      currentPhotoNumber = ProducePhotoNumber.third
    } else if !fourthPhotoSaved {
      currentPhotoNumber = ProducePhotoNumber.fourth
    } else if !fifthPhotoSaved {
      currentPhotoNumber = ProducePhotoNumber.fifth
    }
    
    guard let photoNumber = currentPhotoNumber else {
      let alert = UIAlertController(title: "Info", message: "Please choose which photo you want to update", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    performSegue(withIdentifier: Storyboard.AddProduceToCamera, sender: photoNumber)
  }
  
  
  @IBAction func pictureButtonTouched(_ sender: UIButton) {
    print(sender.tag)
    
    switch sender.tag {
    case 1:
      if firstPhotoSaved {
        performSegue(withIdentifier: Storyboard.AddProduceToCameraRetake, sender: ProducePhotoNumber.first)
      } else {
        performSegue(withIdentifier: Storyboard.AddProduceToCamera, sender: ProducePhotoNumber.first)
      }
    case 2:
      if secondPhotoSaved {
        performSegue(withIdentifier: Storyboard.AddProduceToCameraRetake, sender: ProducePhotoNumber.second)
      } else {
        performSegue(withIdentifier: Storyboard.AddProduceToCamera, sender: ProducePhotoNumber.second)
      }
    case 3:
      
      if thirdPhotoSaved {
        performSegue(withIdentifier: Storyboard.AddProduceToCameraRetake, sender: ProducePhotoNumber.third)
      } else {
        performSegue(withIdentifier: Storyboard.AddProduceToCamera, sender: ProducePhotoNumber.third)
      }
    case 4:
      if fourthPhotoSaved {
        performSegue(withIdentifier: Storyboard.AddProduceToCameraRetake, sender: ProducePhotoNumber.fourth)
      } else {
        performSegue(withIdentifier: Storyboard.AddProduceToCamera, sender: ProducePhotoNumber.fourth)
      }
    case 5:
      if fifthPhotoSaved {
        performSegue(withIdentifier: Storyboard.AddProduceToCameraRetake, sender: ProducePhotoNumber.fifth)
      } else {
        performSegue(withIdentifier: Storyboard.AddProduceToCamera, sender: ProducePhotoNumber.fifth)
      }
    default:
      break
    }
  }
  

  
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.AddProduceToCamera {
      let vc = segue.destination as? CameraVC
      vc?.produceId = "123"
      vc?.photoNumber = sender as? ProducePhotoNumber
      vc?.pictureTaken = pictureTaken
    } else if segue.identifier == Storyboard.AddProduceToCameraRetake {
      let vc = segue.destination as? CameraRetakeVC
      var image: UIImage?
      
      if let number = sender as? ProducePhotoNumber {
        switch number {
        case .first:
          image = onePictureButton.imageView?.image
        case .second:
          image = twoPictureButton.imageView?.image
        case .third:
          image = threePictureButton.imageView?.image
        case .fourth:
          image = fourPictureButton.imageView?.image
        case .fifth:
          image = fivePictureButton.imageView?.image
        }
      }
      
      vc?.image = image
      vc?.number = sender as? ProducePhotoNumber
      vc?.pictureTaken = pictureTaken
    }
  }
  

  func pictureTaken(image: UIImage, number: ProducePhotoNumber) {
    DispatchQueue.main.async { [weak self] in
      switch number {
      case .first:
        self?.firstPhotoSaved = true

        if let state = self?.state {
          if case AddProduceVCState.edit = state {
            self?.firstPhotoEdited = true
          }
        }
        
        self?.firstPhotoEdited = true
        self?.onePictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
      case .second:
        if let state = self?.state {
          if case AddProduceVCState.edit = state {
            self?.secondPhotoEdited = true
          }
        }
        
        self?.secondPhotoSaved = true
        self?.twoPictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
      case .third:
        if let state = self?.state {
          if case AddProduceVCState.edit = state {
            self?.thirdPhotoEdited = true
          }
        }
        
        self?.thirdPhotoSaved = true
        self?.threePictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
      case .fourth:
        if let state = self?.state {
          if case AddProduceVCState.edit = state {
            self?.fourthPhotoEdited = true
          }
        }
        
        self?.fourthPhotoSaved = true
        self?.fourPictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
      case .fifth:
        if let state = self?.state {
          if case AddProduceVCState.edit = state {
            self?.fifthPhotoEdited = true
          }
        }
        
        self?.fifthPhotoSaved = true
        self?.fivePictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
      }
    }
  }
  
  
  @IBAction func planStartButtonTouched() {
    plantStartSelected = !plantStartSelected
    seedStartSelected = false
  }
  
  @IBAction func seedStartButtonTouched() {
    seedStartSelected = !seedStartSelected
    plantStartSelected = false
  }
  
  @IBAction func organicButtonTouched() {
    organicSelected = !organicSelected
  }
  
  @IBAction func compostTeaButtonTouched() {
    compostTeaSelected = !compostTeaSelected
  }
  
  
//  textFieldProduceType.backgroundColor = UIColor.clear
//  textFieldProduceType.layer.cornerRadius = 4
//  textFieldProduceType.layer.borderWidth = 1
//  textFieldProduceType.layer.borderColor = UIColor.white.cgColor
  
//  textFieldProduceType.setValue(CSUtils.colorWithHexString("#cee380"), forKeyPath: "_placeholderLabel.textColor")
  func configureTextComponents() {
    
    makeRoundedButton(onePictureButton)
    makeRoundedButton(twoPictureButton)
    makeRoundedButton(threePictureButton)
    makeRoundedButton(fourPictureButton)
    makeRoundedButton(fivePictureButton)

    configureTextField(textField: produceTypeTextField)
    configureTextField(textField: specificTypeTextField)
    
    
    descriptionTextView.backgroundColor = .clear
//    descriptionTextView
  }
  
  func makeRoundedButton(_ button: UIButton) {
    button.layer.borderColor = UIColor.white.cgColor
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 8
    button.layer.masksToBounds = true
    
    button.imageView?.contentMode = .scaleAspectFill
  }
  
  func configureTextField(textField: UITextField) {
    textField.backgroundColor = .clear
    textField.layer.cornerRadius = 4
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.white.cgColor
    textField.setValue(UIColor.cropswapGreen, forKeyPath: "_placeholderLabel.textColor")
  }
  
  var produceTypeSelected: (name: String, quantityType: String)?
  
  func didProduceTypeSelect(_ produceType: (name: String, quantityType: String)) {
    print(produceType)
//    produceTypeTextField.text = produceType.name
    produceTypeSelected = produceType
    quantityTypeLabel.text = produceType.quantityType
    viewTapped()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if currentUser == nil {
      SVProgressHUD.show()
      User.getUser { [weak self] (result) in
        SVProgressHUD.dismiss()
        
        switch result {
        case .success(let userFound):
          self?.currentUser = userFound
        case .fail(let error):
          print(error)
        }
      }
    }
    
    if let produceId = currentProduceId {
      SVProgressHUD.show()
      Produce.getProduce(byProduceId: produceId, completion: { [weak self] (produce) in
        SVProgressHUD.dismiss()
        self?.currentProduce = produce
        })
    }
    
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let barHeight = self.navigationController?.navigationBar.frame.height ?? 0
    viewTopLayoutConstraint.constant = (statusBarHeight + barHeight) * -1
    
    produceTypeTextField.delegate = self
    
    let blurEffect = UIBlurEffect(style: .dark)
    let visualEffectView = UIVisualEffectView(effect: blurEffect)
    visualEffectView.frame = produceTypeTableView.frame
    
    produceTypeTableView.backgroundView = visualEffectView
    produceTypeTableView.backgroundColor = .clear
    
    
    produceTypeTableView.separatorInset = .zero
    produceTypeTableView.layoutMargins = .zero
    produceTypeTableView.backgroundColor = UIColor.clear
    produceTypeTableView.layer.cornerRadius = 4
    produceTypeTableView.layer.borderWidth = 1
    produceTypeTableView.layer.borderColor = UIColor.cropswapBrown.cgColor
    
    produceTypesDelegate = ProduceTypesDelegate(tableView: produceTypeTableView)
    produceTypesDelegate.setup()
    produceTypesDelegate.didProduceTypeSelect = didProduceTypeSelect
    
    numberFormatter.numberStyle = .currencyAccounting
    numberFormatter.currencyCode = "USD"
    
    configureTextComponents()
    
    setNavBarButtons()
    
    
    
    addDoneButtonOnKeyboard(descriptionTextView)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    tapGesture.cancelsTouchesInView = false
    tapGesture.delegate = self
    view.addGestureRecognizer(tapGesture)
  }
  
  func leftButtonTouched() {
    dismiss(animated: true)
  }

  func rightButtonTouched() {
    
    guard
      let ownerId = currentUser?.id,
      let ownerUsername = currentUser?.name
    else {
      let alert = UIAlertController(title: "Error", message: "No user id or name valid was found.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }

    
    do {
      try areProduceImagesValid()
      let typeOfProduce = try getTypeOfProduce()
      let specificType = try getSpecificType()
      let quantity = try getQuantity()
      let price = try getPrice()
      try areStartTypesValid()
      let description = try getDescription()
      
      let name = specificType
      let produceType = typeOfProduce.name
      
      let quantityType = typeOfProduce.quantityType
      let isCompostTeaSelected = compostTeaSelected
      let isOrganicSelected = organicSelected
      
      let isPlantStart = plantStartSelected
      let isSeedStart = seedStartSelected
      
      guard
        let firstImageData = UIImageJPEGRepresentation(
          onePictureButton.imageView!.image!, 0.2),
        let secondImageData = UIImageJPEGRepresentation(
          twoPictureButton.imageView!.image!, 0.2),
        let thirdImageData = UIImageJPEGRepresentation(
          threePictureButton.imageView!.image!, 0.2),
        let fourthImageData = UIImageJPEGRepresentation(
          fourPictureButton.imageView!.image!, 0.2),
        let fifthImageData = UIImageJPEGRepresentation(
          fivePictureButton.imageView!.image!, 0.2)
        else {
          let alert = UIAlertController(title: "Error", message: "Some of the pictures are not valid, take other ones please.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
          return
      }
      
      var firstPicURL: String?
      var secondPicURL: String?
      var thirdPicURL: String?
      var fourthPicURL: String?
      var fifthPicURL: String?
      
      
      SVProgressHUD.show()
      
      let newProduceId = Produce.generateProduceId()
      
      Ax.serial(tasks: [
        
        { [weak self] done in
          Ax.parallel(tasks: [
            
            { innerDone in
              
              Produce.saveProducePicture(
                pictureData: firstImageData,
                ownerId: ownerId,
                produceId: newProduceId,
                photoNumber: .first,
                completion: { (result) in
                  switch result {
                  case .success(let url):
                    firstPicURL = url
                    innerDone(nil)
                  case .fail(let error):
                    innerDone(error)
                  }
                }
              )
              
            },
            
            { innerDone in
              
              Produce.saveProducePicture(
                pictureData: secondImageData,
                ownerId: ownerId,
                produceId: newProduceId,
                photoNumber: .second,
                completion: { (result) in
                  switch result {
                  case .success(let url):
                    secondPicURL = url
                    innerDone(nil)
                  case .fail(let error):
                    innerDone(error)
                  }
                }
              )
              
            },
            { innerDone in
              
              Produce.saveProducePicture(
                pictureData: thirdImageData,
                ownerId: ownerId,
                produceId: newProduceId,
                photoNumber: .third,
                completion: { (result) in
                  switch result {
                  case .success(let url):
                    thirdPicURL = url
                    innerDone(nil)
                  case .fail(let error):
                    innerDone(error)
                  }
                }
              )
              
            },
            { innerDone in
              
              Produce.saveProducePicture(
                pictureData: fourthImageData,
                ownerId: ownerId,
                produceId: newProduceId,
                photoNumber: .fourth,
                completion: { (result) in
                  switch result {
                  case .success(let url):
                    fourthPicURL = url
                    innerDone(nil)
                  case .fail(let error):
                    innerDone(error)
                  }
                }
              )
              
            },
            { innerDone in
              
              Produce.saveProducePicture(
                pictureData: fifthImageData,
                ownerId: ownerId,
                produceId: newProduceId,
                photoNumber: .fifth,
                completion: { (result) in
                  switch result {
                  case .success(let url):
                    fifthPicURL = url
                    innerDone(nil)
                  case .fail(let error):
                    innerDone(error)
                  }
                }
              )
              
            }
            ], result: { (error) in
              done(error)
          })
        },
        
        { done in
          Produce.saveProduce(
            produceId: newProduceId,
            name: name,
            description: description,
            produceType: produceType,
            quantityType: quantityType,
            quantity: quantity,
            price: price,
//            isCompostTea: isCompostTeaSelected,
//            isOrganic: isOrganicSelected,
//            isSeedStart: isSeedStart,
//            isPlantStart: isPlantStart,
            ownerId: ownerId,
            ownerUsername: ownerUsername,
            
            firstPicURL: firstPicURL ?? "",
            secondPicURL: secondPicURL ?? "",
            thirdPicURL: thirdPicURL ?? "",
            fourthPicURL: fourthPicURL ?? "",
            fifthPicURL: fifthPicURL ?? "",
            
            tags: [(String, Bool, Int, String)](),
            
            state: "",
            
            completion: { (result) in
              switch result {
              case .fail(let error):
                done(error as? NSError)
              case .success(_):
                done(nil)
              }
            }
          )
        }
        
        ], result: { [weak self] (error) in
          SVProgressHUD.dismiss()
          
          if let error = error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
          } else {
            self?.dismiss(animated: true)
          }
        })
      
      
    } catch ValidationFormError.error(let description) {
      SVProgressHUD.dismiss()
      
      let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    } catch {
      print(error)
    }
  }
  
  func areProduceImagesValid() throws {
    if
      !firstPhotoSaved ||
      !secondPhotoSaved ||
      !thirdPhotoSaved ||
      !fourthPhotoSaved ||
        !fifthPhotoSaved {
      scrollView.scrollRectToVisible(onePictureButton.frame, animated: true)
      throw ValidationFormError.error(Constants.ErrorMessages.imagesNotTaken)
    }
  }
  
  func getTypeOfProduce() throws -> (name: String, quantityType: String) {
    if let produceTypeSelected = produceTypeSelected {
      return produceTypeSelected
    } else {
      scrollView.scrollRectToVisible(quantityLabel.frame, animated: true)
      throw ValidationFormError.error(Constants.ErrorMessages.typeOfProduceNotProvided)
    }
  }

  func getSpecificType() throws -> String {
    
    let specificType = specificTypeTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    
    if specificType.characters.count <= 0 {
      scrollView.scrollRectToVisible(specificTypeTextField.frame, animated: true)
      throw ValidationFormError.error(Constants.ErrorMessages.typeOfProduceNotProvided)
    }
    
    return specificType
  }
  
  func getQuantity() throws -> Int {
    if quantity > 0 {
      return quantity
    } else {
      scrollView.scrollRectToVisible(quantityLabel.frame, animated: true)
      throw ValidationFormError.error(Constants.ErrorMessages.quantityNotProvided)
    }
  }
  
  func getPrice() throws -> Double {
    if price > 0 {
      return price
    } else {
      scrollView.scrollRectToVisible(priceLabel.frame, animated: true)
      throw ValidationFormError.error(Constants.ErrorMessages.priceNotProvided)
    }
  }
  
  func areStartTypesValid() throws {
    if !plantStartSelected &&
      !seedStartSelected {
      scrollView.scrollRectToVisible(seedStartButton.frame, animated: true)
      throw ValidationFormError.error(Constants.ErrorMessages.produceNameNotProvided)
    }
  }
  
  func getDescription() throws -> String {
    var description = descriptionTextView.text.trimmingCharacters(in: CharacterSet.whitespaces) 
    
    if description.characters.count > 0 {
      return description
    } else {
      scrollView.scrollRectToVisible(descriptionTextView.frame, animated: true)
      throw ValidationFormError.error(Constants.ErrorMessages.descriptionNotProvided)
    }
  }

  
  func setNavBarButtons() {
    setNavBarColor(color: .cropswapYellow)
    setNavHeaderTitle(title: "Item", color: UIColor.white)
    
    backLeftButton = setNavIcon(imageName: "back-icon", size: CGSize(width: 24, height: 25), position: .left)
    backLeftButton.addTarget(self, action: #selector(leftButtonTouched), for: .touchUpInside)
//    
//    cancelLeftButton = setNavIcon(imageName: "addproduce-cancel-icon", size: CGSize(width: 42, height: 42), position: .left)
////    cancelLeftButton.addTarget(self, action: #selector(leftButtonTouched), for: .touchUpInside)
//    
//    
//    editRightButton = setNavIcon(imageName: "edit-icon", size: CGSize(width: 31, height: 30), position: .right)
////    backLeftButton.addTarget(self, action: #selector(leftButtonTouched), for: .touchUpInside)
//    
//    deleteRightButton = setNavIcon(imageName: "delete-icon", size: CGSize(width: 24, height: 30), position: .right)
//    
//    doneRightButton = setNavIcon(imageName: "addproduce-accept-icon", size: CGSize(width: 35, height: 24), position: .right)
//    
//    saveRightButton = setNavIcon(imageName: "addproduce-save-icon", size: CGSize(width: 41, height: 40), position: .right)

    
    print(navigationItem.rightBarButtonItems)
    
    
//    var backLeftButton: UIButton!
//    var cancelLeftButton: UIButton!
//    
//    var editRightButton: UIButton!
//    var deleteRightButton: UIButton!
//    var doneRightButton: UIButton!
//    var saveRightButton: UIButton!
    
    saveRightButton = setNavIcon(title: "Save", color: UIColor.white, size: CGSize(width: 50, height: 25), position: .right)
    saveRightButton.addTarget(self, action: #selector(rightButtonTouched), for: .touchUpInside)
    
    cancelLeftButton = setNavIcon(title: "Cancel", color: UIColor.white, size: CGSize(width: 60, height: 25), position: .left)
    cancelLeftButton.addTarget(self, action: #selector(cancelButtonTouched), for: .touchUpInside)
    
    
    
    editRightButton = setNavIcon(imageName: "edit-icon", size: CGSize(width: 31, height: 30), position: .right)
    editRightButton.addTarget(self, action: #selector(editButtonTouched), for: .touchUpInside)
    
    deleteRightButton = setNavIcon(imageName: "delete-icon", size: CGSize(width: 24, height: 30), position: .right)
    deleteRightButton.addTarget(self, action: #selector(deleteButtonTouched), for: .touchUpInside)
    
    doneRightButton = setNavIcon(title: "Done", color: UIColor.white, size: CGSize(width: 50, height: 25), position: .right)
    doneRightButton.addTarget(self, action: #selector(doneButtonTouched), for: .touchUpInside)
    
//    let saveRightButton = setNavIcon(title: "Save", color: UIColor.white, size: CGSize(width: 50, height: 25), position: .right)
//    saveRightButton.addTarget(self, action: #selector(rightButtonTouched), for: .touchUpInside)
    
  }
  
  func form(enable: Bool) {
    cameraButton.isUserInteractionEnabled = enable
    onePictureButton.isUserInteractionEnabled = enable
    twoPictureButton.isUserInteractionEnabled = enable
    threePictureButton.isUserInteractionEnabled = enable
    fourPictureButton.isUserInteractionEnabled = enable
    fivePictureButton.isUserInteractionEnabled = enable
    
    produceTypeTextField.isUserInteractionEnabled = enable
    specificTypeTextField.isUserInteractionEnabled = enable
    
    upPriceButton.isUserInteractionEnabled = enable
    downPriceButton.isUserInteractionEnabled = enable
    
    upQuantityButton.isUserInteractionEnabled = enable
    downQuantityButton.isUserInteractionEnabled = enable
    
    plantStartButton.isUserInteractionEnabled = enable
    seedStartButton.isUserInteractionEnabled = enable
    organicButton.isUserInteractionEnabled = enable
    compostTeaButton.isUserInteractionEnabled = enable
    
    descriptionTextView.isUserInteractionEnabled = enable
  }
  
  func editButtonTouched() {
    state = .edit
  }
  
  func deleteButtonTouched() {
    let alert = UIAlertController(title: "Info", message: "Are you sure you want to delete this produce?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
      print("cancel touched")
    })
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
      print("OK touched")
      guard
        let produceId = self?.currentProduceId,
        let ownerId = self?.currentUser?.id
      else {
        let alert = UIAlertController(title: "Error", message: "No produce id or owner id was found.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self?.present(alert, animated: true)
        return
      }
      
      
      SVProgressHUD.show()
      Produce.deleteProduce(
        id: produceId,
        firstPicURL: self?.currentProduce?.firstPictureURL,
        secondPicURL: self?.currentProduce?.secondPictureURL,
        thirdPicURL: self?.currentProduce?.thirdPictureURL,
        fourthPicURL: self?.currentProduce?.fourthPictureURL,
        fifthPicURL: self?.currentProduce?.fifthPictureURL,
        ownerId: ownerId,
        completion: { (error) in
          SVProgressHUD.dismiss()
          
          if let error = error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self?.present(alert, animated: true)
          } else {
            self?.dismiss(animated: true)
          }
      })
    }))
    
    present(alert, animated: true)
  }
  
  func cancelButtonTouched() {
    loadProduceToUI()
    state = .read
    
    firstPhotoEdited = false
    secondPhotoEdited = false
    thirdPhotoEdited = false
    fourthPhotoEdited = false
    fifthPhotoEdited = false
  }
  
  func doneButtonTouched() {

    guard
      let ownerId = currentUser?.id,
      let produceId = currentProduceId
    else {
        let alert = UIAlertController(title: "Error", message: "No user id or produce id valid was found.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        return
    }
    
    
    do {
      try areProduceImagesValid()
      let typeOfProduce = try getTypeOfProduce()
      let specificType = try getSpecificType()
      let quantity = try getQuantity()
      let price = try getPrice()
      try areStartTypesValid()
      let description = try getDescription()
      
      let name = specificType
      let produceType = typeOfProduce.name
      
      let quantityType = typeOfProduce.quantityType
      let isCompostTeaSelected = compostTeaSelected
      let isOrganicSelected = organicSelected
      
      let isPlantStart = plantStartSelected
      let isSeedStart = seedStartSelected
      
      
      guard
        let firstImageData = UIImageJPEGRepresentation(
          onePictureButton.imageView!.image!, 0.2),
        let secondImageData = UIImageJPEGRepresentation(
          twoPictureButton.imageView!.image!, 0.2),
        let thirdImageData = UIImageJPEGRepresentation(
          threePictureButton.imageView!.image!, 0.2),
        let fourthImageData = UIImageJPEGRepresentation(
          fourPictureButton.imageView!.image!, 0.2),
        let fifthImageData = UIImageJPEGRepresentation(
          fivePictureButton.imageView!.image!, 0.2)
      else {
          let alert = UIAlertController(title: "Error", message: "Some of the pictures are not valid, take other ones please.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
          return
      }
      
      var firstPicURL: String?
      var secondPicURL: String?
      var thirdPicURL: String?
      var fourthPicURL: String?
      var fifthPicURL: String?
      
      SVProgressHUD.show()
      
      Ax.serial(tasks: [
        { [weak self] done in
          Ax.parallel(tasks: [
            
            { innerDone in
              if self?.firstPhotoEdited ?? false {
                Produce.saveProducePicture(
                  pictureData: firstImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .first,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      firstPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
              
            },
            
            { innerDone in
              if self?.secondPhotoEdited ?? false {
                Produce.saveProducePicture(
                  pictureData: secondImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .second,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      secondPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
              
            },
            { innerDone in
              
              if self?.thirdPhotoEdited ?? false {
                Produce.saveProducePicture(
                  pictureData: thirdImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .third,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      thirdPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }

                  }
                )
              } else {
                innerDone(nil)
              }
              
            },
            { innerDone in
              
              if self?.fourthPhotoEdited ?? false {
                Produce.saveProducePicture(
                  pictureData: fourthImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .fourth,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      fourthPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
              
            },
            { innerDone in
              
              if self?.fifthPhotoEdited ?? false {
                Produce.saveProducePicture(
                  pictureData: fifthImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .fifth,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      fifthPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
            }
            
            ], result: { (error) in
              done(error)
          })
        },
        { done in
          
          print("first pic \(firstPicURL)")
          print("second pic \(secondPicURL)")
          print("third pic \(thirdPicURL)")
          print("fourth pic \(fourthPicURL)")
          print("fifth pic \(fifthPicURL)")
          
          Produce.updateProduce(
            produceId: produceId,
            name: name,
            description: description,
            produceType: produceType,
            quantityType: quantityType,
            quantity: quantity,
            price: price,
//            isCompostTea: isCompostTeaSelected,
//            isOrganic: isOrganicSelected,
//            isSeedStart: isSeedStart,
//            isPlantStart: isPlantStart,
            ownerId: ownerId,
            firstPicURL: firstPicURL,
            secondPicURL: secondPicURL,
            thirdPicURL: thirdPicURL,
            fourthPicURL: fourthPicURL,
            fifthPicURL: fifthPicURL,
            
            tags: [],
            state: "",
            completion: { (result) in
              switch result {
              case .fail(let error):
                done(error as? NSError)
              case .success(_):
                done(nil)
              }
            }
          )
        }
        ], result: { [weak self] (error) in
          SVProgressHUD.dismiss()
          if let error = error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
          } else {
            self?.dismiss(animated: true)
          }
        })
    } catch ValidationFormError.error(let description) {
      SVProgressHUD.dismiss()
      
      let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    } catch {
      print(error)
    }
  }
  
  func loadProduceToUI() {
    if let produce = currentProduce {
      
      DispatchQueue.main.async { [weak self] in
        let firstPicURL = produce.firstPictureURL
        let secondPicURL = produce.secondPictureURL
        let thirdPicURL = produce.thirdPictureURL
        let fourthPicURL = produce.fourthPictureURL
        let fifthPicURL = produce.fifthPictureURL
        
        let produceType = produce.produceType
        let specificType = produce.name
        
        let price = produce.price
        let quantity = produce.quantity
        let quantityType = produce.quantityType
        
        let isOrganic = produce.isOrganic
        let isCompostTea = produce.isCompostTea
        
        let isSeedStart = produce.isSeedStart
        let isPlantStart = produce.isPlantStart
        
        let description = produce.description
        
        
        if let firstPicURL = firstPicURL {
          self?.firstPhotoSaved = true
          self?.onePictureButton.sd_setImage(with: URL(string: firstPicURL), for: .normal, completed: { image, _, _, _ in
            self?.onePictureButton.setImage(self?.onePictureButton.image(for: .normal), for: .normal)
            
            if let image = image {
              self?.onePictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            }
          })
        }
        
        if let secondPicURL = secondPicURL {
          self?.secondPhotoSaved = true
          self?.twoPictureButton.sd_setImage(with: URL(string: secondPicURL), for: .normal) { image, _, _, _ in
            if let image = image {
              self?.twoPictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            }
          }
        }
        
        if let thirdPicURL = thirdPicURL {
          self?.thirdPhotoSaved = true
          self?.threePictureButton.sd_setImage(with: URL(string: thirdPicURL), for: .normal) { image, _, _, _ in
            if let image = image {
              self?.threePictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            }
          }
        }
        
        if let fourthPicURL = fourthPicURL {
          self?.fourthPhotoSaved = true
          self?.fourPictureButton.sd_setImage(with: URL(string: fourthPicURL), for: .normal) {  image, _, _, _ in
            if let image = image {
              self?.fourPictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            }
          }
        }
        
        if let fifthPicURL = fifthPicURL {
          self?.fifthPhotoSaved = true
          self?.fivePictureButton.sd_setImage(with: URL(string: fifthPicURL), for: .normal) {  image, _, _, _ in
            if let image = image {
              self?.fivePictureButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            }
          }
        }
        
        
        self?.price = price
        
        self?.quantity = quantity
        
        self?.quantityType = quantityType
        
        self?.descriptionPlaceHolderLabel.isHidden = true
        self?.descriptionTextView.text = description
        
//        self?.organicSelected = isOrganic
//        self?.compostTeaSelected = isCompostTea
//        
//        self?.plantStartSelected = isPlantStart
//        self?.seedStartSelected = isSeedStart
        
        self?.specificTypeTextField.text = specificType
        
        self?.produceTypeTextField.text = produceType
        
        self?.produceTypeSelected = (name: produceType, quantityType: quantityType)
      }
      
    }
  }
  
  func hideButton(button: UIButton, animation: Bool) {
    
    if animation {
      UIView.animate(withDuration: 0.5) {
        button.alpha = 0
        
        let buttonSize = CGSize(width: 0, height: button.frame.height)
        button.frame.size = buttonSize
      }
    } else {
      button.alpha = 0
      let buttonSize = CGSize(width: 0, height: button.frame.height)
      button.frame.size = buttonSize
    }
  }
  
  func showButton(button: UIButton, width: CGFloat, animation: Bool) {
    
    if animation {
      UIView.animate(withDuration: 0.5) {
        button.alpha = 1
        
        let buttonSize = CGSize(width: width, height: button.frame.height)
        button.frame.size = buttonSize
      }
      
    } else {
      button.alpha = 1
      
      let buttonSize = CGSize(width: width, height: button.frame.height)
      button.frame.size = buttonSize
      
    }
  }
  
  func addDoneButtonOnKeyboard(_ control: UITextView) {
    let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 30)) //50
    doneToolbar.barStyle = UIBarStyle.default
    
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(viewTapped))
    
    let navBarFont = UIFont(name: "OpenSans-Light", size: 17)
    
    let navBarAttributesDictionary: [String: AnyObject]? = [
      NSForegroundColorAttributeName: UIColor.cropswapRed,
      NSFontAttributeName: navBarFont!
    ]
    
    done.setTitleTextAttributes(navBarAttributesDictionary, for: .normal)
    
    
    var items = [UIBarButtonItem]()
    items.append(flexSpace)
    items.append(done)
    
    doneToolbar.items = items
    doneToolbar.sizeToFit()
    
    control.inputAccessoryView = doneToolbar
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    print(currentState)
    state = currentState ?? .read
    
    edgesForExtendedLayout = []
    
    

    scrollView.contentInset = originalContentInsets
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardIsShown(_:)),
      name: NSNotification.Name.UIKeyboardDidShow,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardIsDimissed(_:)),
      name: Notification.Name.UIKeyboardWillHide,
      object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
    
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
  }
  
  func viewTapped() {
    view.endEditing(true)
  }
  
  var originalContentInsets = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
  
  func keyboardIsShown(_ notification: Notification) {
    let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
  
    var rect = self.view.frame
    rect.size.height -= keyboardHeight
//    originalContentInsets = scrollView.contentInset
    
//    print(scrollView.contentInset)
//    print(scrollView.scrollIndicatorInsets)
    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    
    UIView.animate(withDuration: 0.5) { [weak self] in
      self?.scrollView.contentInset = contentInsets
      self?.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    if isDescriptionTextViewFocused
//      && !rect.contains(descriptionTextView.frame.origin)
    {
      
//      scrollView.contentInset = contentInsets
//      scrollView.scrollIndicatorInsets = contentInsets
      
      scrollView.scrollRectToVisible(descriptionTextView.frame, animated: true)
    }
  }
  
  func keyboardIsDimissed(_ notification: Notification) {
//    let contentInset = UIEdgeInsets.zero
    print(originalContentInsets)
    scrollView.contentInset = originalContentInsets
    scrollView.scrollIndicatorInsets = originalContentInsets
  }
  
  var isDescriptionTextViewFocused = false
}

extension AddProduceVC: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    isDescriptionTextViewFocused = false
    
    if textField === produceTypeTextField {
//      produceTypeTableView.isHidden = false
      produceTypeTableViewIsHidden = false
    }
  }
  
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField === produceTypeTextField {
      let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
      produceTypeSelected = nil
      
      produceTypesDelegate.filterProduces(byText: newString)
    }
    
    return true
  }
  
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//    
//    if textField === produceTypeTextField {
//      let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
//      produceTypeSelected = nil
//      
//      
//    }
//    
//    return true
//  }
  
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField === produceTypeTextField {
//      produceTypeTableView.isHidden = true
      produceTypeTableViewIsHidden = true
      textField.text = produceTypeSelected?.name ?? ""
    }
  }
  
  override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  
  
}

extension AddProduceVC: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if let view = touch.view,
      view.isDescendant(of: produceTypeTableView) {
      return false
    }
    
    return true
  }
}

extension AddProduceVC: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView === descriptionTextView {
      isDescriptionTextViewFocused = true
      
      descriptionPlaceHolderLabel.isHidden = true
    } else {
      isDescriptionTextViewFocused = false
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    if textView === descriptionTextView {
      descriptionPlaceHolderLabel.isHidden = textView.text.characters.count > 0
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView === descriptionTextView {
      descriptionPlaceHolderLabel.isHidden = textView.text.characters.count > 0
      isDescriptionTextViewFocused = false
    }
  }
  
}


















