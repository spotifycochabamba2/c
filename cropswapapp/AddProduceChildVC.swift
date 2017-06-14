//
//  AddProduceChildVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddProduceChildVC: UITableViewController {
  var currentProduceId: String?
  var currentProduce: Produce?
  var currentProduceState: String?
  
  @IBOutlet weak var photoOptionsView: UIView!
  
  @IBOutlet weak var firstPhotoButton: UIButton! {
    didSet {
      firstPhotoButton.imageView?.contentMode = .scaleAspectFill
      firstPhotoButton.layer.masksToBounds = true
    }
  }
  
  @IBOutlet weak var secondPhotoButton: UIButton! {
    didSet {
      secondPhotoButton.imageView?.contentMode = .scaleAspectFill
      secondPhotoButton.layer.masksToBounds = true
    }
  }
  
  @IBOutlet weak var thirdPhotoButton: UIButton! {
    didSet {
      thirdPhotoButton.imageView?.contentMode = .scaleAspectFill
      thirdPhotoButton.layer.masksToBounds = true
    }
  }
  
  @IBOutlet weak var fourthPhotoButton: UIButton! {
    didSet {
      fourthPhotoButton.imageView?.contentMode = .scaleAspectFill
      fourthPhotoButton.layer.masksToBounds = true
    }
  }
  
  @IBOutlet weak var fifthPhotoButton: UIButton! {
    didSet {
      fifthPhotoButton.imageView?.contentMode = .scaleAspectFill
      fifthPhotoButton.layer.masksToBounds = true
    }
  }
  
  @IBOutlet weak var firstPhotoDeleteImageView: UIImageView!
  @IBOutlet weak var secondPhotoDeleteImageView: UIImageView!
  @IBOutlet weak var thirdPhotoDeleteImageView: UIImageView!
  @IBOutlet weak var fourthPhotoDeleteImageView: UIImageView!
  @IBOutlet weak var fifthPhotoDeleteImageView: UIImageView!
  
  @IBOutlet weak var firstPhotoDeleteButton: UIButton!
  @IBOutlet weak var secondPhotoDeleteButton: UIButton!
  @IBOutlet weak var thirdPhotoDeleteButton: UIButton!
  @IBOutlet weak var fourthPhotoDeleteButton: UIButton!
  @IBOutlet weak var fifthPhotoDeleteButton: UIButton!
  
  var isFirstPhotoDeleteButtonHidden = false {
    didSet {
      if isFirstPhotoDeleteButtonHidden {
        firstPhotoDeleteButton.isHidden = true
        firstPhotoDeleteImageView.isHidden = true
        
      } else {
        firstPhotoDeleteButton.isHidden = false
        firstPhotoDeleteImageView.isHidden = false
      }
    }
  }
  
  var isSecondPhotoDeleteButtonHidden = false {
    didSet {
      if isSecondPhotoDeleteButtonHidden {
        secondPhotoDeleteButton.isHidden = true
        secondPhotoDeleteImageView.isHidden = true
      } else {
        secondPhotoDeleteButton.isHidden = false
        secondPhotoDeleteImageView.isHidden = false
      }
    }
  }
  
  var isThirdPhotoDeleteButtonHidden = false {
    didSet {
      if isThirdPhotoDeleteButtonHidden {
        thirdPhotoDeleteButton.isHidden = true
        thirdPhotoDeleteImageView.isHidden = true
      } else {
        thirdPhotoDeleteButton.isHidden = false
        thirdPhotoDeleteImageView.isHidden = false
      }
    }
  }
  
  var isFourthPhotoDeleteButtonHidden = false {
    didSet {
      if isFourthPhotoDeleteButtonHidden {
        fourthPhotoDeleteButton.isHidden = true
        fourthPhotoDeleteImageView.isHidden = true
      } else {
        fourthPhotoDeleteButton.isHidden = false
        fourthPhotoDeleteImageView.isHidden = false
      }
    }
  }
  
  var isFifthPhotoDeleteButtonHidden = false {
    didSet {
      if isFifthPhotoDeleteButtonHidden {
        fifthPhotoDeleteButton.isHidden = true
        fifthPhotoDeleteImageView.isHidden = true
      } else {
        fifthPhotoDeleteButton.isHidden = false
        fifthPhotoDeleteImageView.isHidden = false
      }
    }
  }
  
//  @IBOutlet weak var takePictureButton: UIButton!
//  @IBOutlet weak var choosePictureButton: UIButton!
  
  @IBOutlet weak var stateLabelView: UIView!
  @IBOutlet weak var stateLabelViewConstraint: NSLayoutConstraint!
  let tagCellId = "TagCellId"
  
  var unitSelected: String?
  
  var tagsSelected = [(String, Bool, Int, String)]()
  
  var tagsToDisplay = [String]()
  var tagsToSave = [String: Any]()
  
  var stateSelected: String? {
    didSet {
      isSeedTypeSelected = false
      isPlantTypeSelected = false
      isHarvestTypeSelected = false
      isOtherTypeSelected = false
      
      if let stateSelected = stateSelected {
        switch stateSelected {
        case ProduceStartType.seed.rawValue:
          isSeedTypeSelected = true
        case ProduceStartType.plant.rawValue:
          isPlantTypeSelected = true
        case ProduceStartType.harvest.rawValue:
          isHarvestTypeSelected = true
        case ProduceStartType.other.rawValue:
          fallthrough
        default:
          isOtherTypeSelected = true
          break
        }
      }
    }
  }
  
  @IBOutlet weak var stateLabel: UILabel!
  
//  @IBOutlet weak var stateCollectionView: TagsCollectionView!
  @IBOutlet weak var tagsCollectionView: TagsCollectionView!
  
  @IBOutlet weak var unitTextField: UITextField!
  @IBOutlet weak var priceUnitLabel: UILabel!
//  @IBOutlet weak var deletePictureButton: UIButton!
  
  @IBOutlet weak var firstCell: UITableViewCell!
  
  @IBOutlet weak var categoriesViewBottomConstraint: NSLayoutConstraint!
  
  var categoriesTableViewDelegate: ProduceTypesDelegate!
  @IBOutlet weak var categoriesTableView: UITableView!
  
  @IBOutlet weak var thirdCell: UITableViewCell!
  var thirdCellHeight: CGFloat = 80
  var thirdCellSelected = false
  
  let montserratFont = UIFont(name: "Montserrat-Regular", size: 9)
  var tagFontAttributes: [String: UIFont]?
  
  // page container properties
//  var pageContainer: UIPageViewController!
  var currentIndex = 0
  var pendingIndex = 0
  var produceImagesViewControllers = [UIViewController]()
  
  var firstPhotoEdited = false
  var secondPhotoEdited = false
  var thirdPhotoEdited = false
  var fourthPhotoEdited = false
  var fifthPhotoEdited = false
  
  var changeTitleButton: (String) -> Void = { _ in }
  var enableProcessButton: () -> Void = { _ in }
  
//  @IBOutlet weak var nextButton: UIButton!
  
  
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
  
  func photoOptionsViewNotShowed() -> Bool {
    if photoOptionsView.alpha == 0 {
      return true
    }
    
    showPhotoOptionsView = false
    
    return false
  }
  
  @IBOutlet weak var seedTypeButton: UIButton!
  @IBOutlet weak var plantTypeButton: UIButton!
  @IBOutlet weak var harvestTypeButton: UIButton!
  @IBOutlet weak var otherTypeButton: UIButton!
  
  var isSeedTypeSelected = false {
    didSet {
      if isSeedTypeSelected {
        seedTypeButton.setImage(UIImage(named: "seed-type-color-icon"), for: .normal)
      } else {
        seedTypeButton.setImage(UIImage(named: "seed-type-icon"), for: .normal)
      }
    }
  }
  
  var isPlantTypeSelected = false {
    didSet {
      if isPlantTypeSelected {
        plantTypeButton.setImage(UIImage(named: "plant-type-color-icon"), for: .normal)
      } else {
        plantTypeButton.setImage(UIImage(named: "plant-type-icon"), for: .normal)
      }
    }
  }
  
  var isHarvestTypeSelected = false {
    didSet {
      if isHarvestTypeSelected {
        harvestTypeButton.setImage(UIImage(named: "harvest-type-color-icon"), for: .normal)
      } else {
        harvestTypeButton.setImage(UIImage(named: "harvest-type-icon"), for: .normal)
      }
    }
  }
  
  var isOtherTypeSelected = false {
    didSet {
      if isOtherTypeSelected {
        otherTypeButton.setImage(UIImage(named: "other-type-color-icon"), for: .normal)
      } else {
        otherTypeButton.setImage(UIImage(named: "other-type-icon"), for: .normal)
      }
    }
  }
  
  
  @IBAction func seedButtonTouched() {
    changeTitleButton("SAVE")
    didSelectState(state: ProduceStartType.seed.rawValue)
  }
  
  @IBAction func plantButtonTouched() {
    changeTitleButton("SAVE")
    didSelectState(state: ProduceStartType.plant.rawValue)
  }
  
  @IBAction func harvestButtonTouched() {
    changeTitleButton("SAVE")
    didSelectState(state: ProduceStartType.harvest.rawValue)
  }
  
  @IBAction func otherButtonTouched() {
    changeTitleButton("SAVE")
    didSelectState(state: ProduceStartType.other.rawValue)
  }
  
  @IBAction func takePhotoButtonTouched() {
    print("take photo button touched")
    
    changeTitleButton("SAVE")
//    var currentPhotoNumber: ProducePhotoNumber?
    
//    switch currentIndex {
//    case 0:
//      if firstPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.first
//      }
//    case 1:
//      if secondPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.second
//      }
//    case 2:
//      if thirdPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.third
//      }
//    case 3:
//      if fourthPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.fourth
//      }
//    case 4:
//      if fifthPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.fifth
//      }
//    default:
//      break
//    }
    
    performSegue(withIdentifier: Storyboard.AddProduceChildToCamera, sender: currentIndex)
    
//    // old picture, wants to update it
//    if let _ = currentPhotoNumber {
//      performSegue(withIdentifier: Storyboard.AddProduceChildToRetakeCamera, sender: currentIndex)
//    } else {// new picture
//      performSegue(withIdentifier: Storyboard.AddProduceChildToCamera, sender: currentIndex)
//    }
    
  }
  
  @IBAction func uploadPhotoButtonTouched() {
    changeTitleButton("SAVE")
    
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let imagePicker = UIImagePickerController()
      
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      
      present(imagePicker, animated: true, completion: nil)
    }
  }
  
  func showConfirmationAlert(message: String, completion: @escaping (Bool) -> Void) {
    let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
      completion(false)
    }))
    
    alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
      completion(true)
    }))
    
    present(alert, animated: true)
  }
  
  @IBAction func firstPhotoDeleteButtonTouched() {
    if photoOptionsViewNotShowed() {
      showConfirmationAlert(
        message: "Are you sure you want to delete this picture?",
        completion: { [weak self] (confirmed) in
        print(confirmed)
          if confirmed,
            let this = self {
//            switch this.currentIndex {
//            case 0:
//              this.firstPhotoSaved = false
//            case 1:
//              this.secondPhotoSaved = false
//            case 2:
//              this.thirdPhotoSaved = false
//            case 3:
//              this.fourthPhotoSaved = false
//            case 4:
//              this.fifthPhotoSaved = false
//            default:
//              break
//            }
            
            this.firstPhotoSaved = false
            
            DispatchQueue.main.async {
              this.firstPhotoButton.setImage(nil, for: .normal)
              this.isFirstPhotoDeleteButtonHidden = true
            }
            
            this.printImagesAreSaved()
          }
      })
    }
  }
  
  func printImagesAreSaved() {
    print("firstPhotoSaved: \(firstPhotoSaved)")
    print("secondPhotoSaved: \(secondPhotoSaved)")
    print("thirdPhotoSaved: \(thirdPhotoSaved)")
    print("fourthPhotoSaved: \(fourthPhotoSaved)")
    print("fifthPhotoSaved: \(fifthPhotoSaved)")
  }
  
  @IBAction func secondPhotoDeleteButtonTouched() {
    if photoOptionsViewNotShowed() {
      showConfirmationAlert(
        message: "Are you sure you want to delete this picture?",
        completion: { [weak self] (confirmed) in
          print(confirmed)
          
          if confirmed,
            let this = self {
//            switch this.currentIndex {
//            case 0:
//              this.firstPhotoSaved = false
//            case 1:
//              this.secondPhotoSaved = false
//            case 2:
//              this.thirdPhotoSaved = false
//            case 3:
//              this.fourthPhotoSaved = false
//            case 4:
//              this.fifthPhotoSaved = false
//            default:
//              break
//            }
            this.secondPhotoSaved = false
            
            DispatchQueue.main.async {
              this.secondPhotoButton.setImage(nil, for: .normal)
              this.isSecondPhotoDeleteButtonHidden = true
            }
            
            this.printImagesAreSaved()
          }
      })
    }
    
    print("delete button touched")
  }
  
  @IBAction func thirdPhotoDeleteButtonTouched() {
    if photoOptionsViewNotShowed() {
      showConfirmationAlert(
        message: "Are you sure you want to delete this picture?",
        completion: { [weak self] (confirmed) in
          print(confirmed)
          
          if confirmed,
            let this = self {
//            switch this.currentIndex {
//            case 0:
//              this.firstPhotoSaved = false
//            case 1:
//              this.secondPhotoSaved = false
//            case 2:
//              this.thirdPhotoSaved = false
//            case 3:
//              this.fourthPhotoSaved = false
//            case 4:
//              this.fifthPhotoSaved = false
//            default:
//              break
//            }
            
            this.thirdPhotoSaved = false
            
            DispatchQueue.main.async {
              this.thirdPhotoButton.setImage(nil, for: .normal)
              this.isThirdPhotoDeleteButtonHidden = true
            }
            
            this.printImagesAreSaved()
          }
      })
    }
    print("delete button touched")
  }
  
  @IBAction func fourthPhotoDeleteButtonTouched() {
    if photoOptionsViewNotShowed() {
      showConfirmationAlert(
        message: "Are you sure you want to delete this picture?",
        completion: { [weak self] (confirmed) in
          print(confirmed)
          
          if confirmed,
            let this = self {
//            switch this.currentIndex {
//            case 0:
//              this.firstPhotoSaved = false
//            case 1:
//              this.secondPhotoSaved = false
//            case 2:
//              this.thirdPhotoSaved = false
//            case 3:
//              this.fourthPhotoSaved = false
//            case 4:
//              this.fifthPhotoSaved = false
//            default:
//              break
//            }
            
            this.fourthPhotoSaved = false
            
            DispatchQueue.main.async {
              this.fourthPhotoButton.setImage(nil, for: .normal)
              this.isFourthPhotoDeleteButtonHidden = true
            }
            
            this.printImagesAreSaved()
          }
      })
    }
    print("delete button touched")
  }
  
  @IBAction func fifthPhotoDeleteButtonTouched() {
    if photoOptionsViewNotShowed() {
      showConfirmationAlert(
        message: "Are you sure you want to delete this picture?",
        completion: { [weak self] (confirmed) in
          print(confirmed)
          
          if confirmed,
            let this = self {
//            switch this.currentIndex {
//            case 0:
//              this.firstPhotoSaved = false
//            case 1:
//              this.secondPhotoSaved = false
//            case 2:
//              this.thirdPhotoSaved = false
//            case 3:
//              this.fourthPhotoSaved = false
//            case 4:
//              this.fifthPhotoSaved = false
//            default:
//              break
//            }
            
            this.fifthPhotoSaved = false
            DispatchQueue.main.async {
              this.fifthPhotoButton.setImage(nil, for: .normal)
              this.isFifthPhotoDeleteButtonHidden = true
//              this.fifthPhotoButton.imageView?.image = nil
            }
            
            this.printImagesAreSaved()
          }
      })
    }
  }
  
  
  
  @IBAction func firstPhotoButtonTouched() {
    if firstPhotoSaved {
      performSegue(withIdentifier: Storyboard.AddProduceChildToImageDetail, sender: firstPhotoButton.imageView?.image)
      return
    }
    
    if photoOptionsViewNotShowed() {
      showPhotoOptionsView = true
      currentIndex = 0
    }
  }
  
  @IBAction func secondPhotoButtonTouched() {
    if secondPhotoSaved {
      performSegue(withIdentifier: Storyboard.AddProduceChildToImageDetail, sender: secondPhotoButton.imageView?.image)
      return
    }
    
    if photoOptionsViewNotShowed() {
      showPhotoOptionsView = true
      currentIndex = 1
    }
    print("photo button touched")
  }
  
  @IBAction func thirdPhotoButtonTouched() {
    if thirdPhotoSaved {
      performSegue(withIdentifier: Storyboard.AddProduceChildToImageDetail, sender: thirdPhotoButton.imageView?.image)
      return
    }
    
    if photoOptionsViewNotShowed() {
      showPhotoOptionsView = true
      currentIndex = 2
    }
    print("photo button touched")
  }
  
  @IBAction func fourthPhotoButtonTouched() {
    if fourthPhotoSaved {
      performSegue(withIdentifier: Storyboard.AddProduceChildToImageDetail, sender: fourthPhotoButton.imageView?.image)
      return
    }
    
    if photoOptionsViewNotShowed() {
      showPhotoOptionsView = true
      currentIndex = 3
    }
    print("photo button touched")
  }
  
  @IBAction func fifthPhotoButtonTouched() {
    if fifthPhotoSaved {
      performSegue(withIdentifier: Storyboard.AddProduceChildToImageDetail, sender: fifthPhotoButton.imageView?.image)
      return
    }
    
    if photoOptionsViewNotShowed() {
      showPhotoOptionsView = true
      currentIndex = 4
    }
    print("photo button touched")
  }
  
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
  
  func getProduceImages() -> [UIImage] {
    var images = [UIImage]()
    
    if firstPhotoSaved {
      if let image = firstPhotoButton.image(for: .normal) {
        images.append(image)
      }
    }
    
    if secondPhotoSaved {
      if let image = secondPhotoButton.image(for: .normal) {
        images.append(image)
      }
    }
    
    if thirdPhotoSaved {
      if let image = thirdPhotoButton.image(for: .normal) {
        images.append(image)
      }
    }
    
    if fourthPhotoSaved {
      if let image = fourthPhotoButton.image(for: .normal) {
        images.append(image)
      }
    }
    
    if fifthPhotoSaved {
      if let image = fifthPhotoButton.image(for: .normal) {
        images.append(image)
      }
    }
    
    return images
  }
  
  func getProduceName() throws -> String {
    let produceNameText = produceNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    
    if produceNameText.characters.count > 0 {
      return produceNameText
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.produceNameNotProvided)
    }
  }
  
  func getStateSelected() throws -> String {
    if let state = stateSelected {
      return state
    }
    
    throw ValidationFormError.error(Constants.ErrorMessages.stateNotSelected)
  }

  
  @IBOutlet weak var produceNameTextField: UITextField!
  @IBOutlet weak var chooseCategoryTextField: UITextField!
  @IBOutlet weak var quantityTextField: UITextField!
  @IBOutlet weak var priceUnitTextField: UITextField!
//  @IBOutlet weak var descriptionTextField: UITextField!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var csDescriptionTextView: CSTextView!
  
  @IBOutlet weak var shadowViewForPickProductsButton: UIView!
  @IBOutlet weak var shadowViewForPickStateButton: UIView!
  
  @IBOutlet weak var pickStateButton: UIButton!
  
  @IBOutlet weak var pickProductsButton: UIButton! {
    didSet {
      
    }
  }
  
  var produceTypeSelected: (name: String, quantityType: String)?
  
  func didCategorySelect(_ produceType: (name: String, quantityType: String)) {
    print(produceType)
    changeTitleButton("SAVE")

    produceTypeSelected = produceType
    chooseCategoryTextField.text = produceType.name

    rootViewTapped()
  }
  
  func rootViewTapped() {
    view.endEditing(true)
  }
  
  func loadProduceToUI(_ produce: Produce?) {
    if let produce = produce {
      
      if let firstPicURL = produce.firstPictureURL?.trimmingCharacters(in: CharacterSet.whitespaces),
        !firstPicURL.isEmpty
      {
        if let url = URL(string: firstPicURL) {
          firstPhotoButton.sd_setImage(
            with: url,
            for: .normal,
            completed: { [weak self] (_, error, _, _) in
            if error == nil {
              self?.firstPhotoSaved = true
              self?.firstPhotoDeleteButton.isHidden = false
              self?.isFirstPhotoDeleteButtonHidden = false
            }
          })
        }
        
      }
      
      if let secondPicURL = produce.secondPictureURL?.trimmingCharacters(in: CharacterSet.whitespaces),
        !secondPicURL.isEmpty
      {
        if let url = URL(string: secondPicURL) {
          secondPhotoButton.sd_setImage(
            with: url,
            for: .normal,
            completed: { [weak self] (_, error, _, _) in
              if error == nil {
                self?.secondPhotoSaved = true
                self?.secondPhotoDeleteButton.isHidden = false
                self?.isSecondPhotoDeleteButtonHidden = false
              }
            })
        }
      }
      
      if let thirdPicURL = produce.thirdPictureURL?.trimmingCharacters(in: CharacterSet.whitespaces),
        !thirdPicURL.isEmpty
      {
        if let url = URL(string: thirdPicURL) {
          thirdPhotoButton.sd_setImage(
            with: url,
            for: .normal,
            completed: { [weak self] (_, error, _, _) in
              if error == nil {
                self?.thirdPhotoSaved = true
                self?.thirdPhotoDeleteButton.isHidden = false
                self?.isThirdPhotoDeleteButtonHidden = false
              }
            })
        }
      }
      
      if let fourthPicURL = produce.fourthPictureURL?.trimmingCharacters(in: CharacterSet.whitespaces),
        !fourthPicURL.isEmpty
      {
        if let url = URL(string: fourthPicURL) {
          fourthPhotoButton.sd_setImage(
            with: url,
            for: .normal,
            completed: { [weak self] (_, error, _, _) in
              if error == nil {
                self?.fourthPhotoSaved = true
                self?.fourthPhotoDeleteButton.isHidden = false
                self?.isFourthPhotoDeleteButtonHidden = false
              }
            })
        }
      }
      
      if let fifthPicURL = produce.fifthPictureURL?.trimmingCharacters(in: CharacterSet.whitespaces),
        !fifthPicURL.isEmpty
      {
//        let vc = produceImagesViewControllers[4] as! ProduceImageVC
//        vc.produceImageURL = fifthPicURL
//        fifthPhotoSaved = true
        if let url = URL(string: fifthPicURL) {
          fifthPhotoButton.sd_setImage(
            with: url,
            for: .normal,
            completed: { [weak self] (_, error, _, _) in
              if error == nil {
                self?.fifthPhotoSaved = true
                self?.fifthPhotoDeleteButton.isHidden = false
                self?.isFifthPhotoDeleteButtonHidden = false
              }
            })
        }
      }
      
      didSelectState(state: produce.state)
      didSelectUnit(unit: produce.quantityType)
//      stateSelected = produce.stat
      
//      unitTextField
      unitTextField.text = produce.quantityType
      produceTypeSelected = (name: produce.produceType, quantityType: produce.quantityType)
      
      produceNameTextField.text = produce.name
//      chooseCategoryTextField.text = "\(produce.produceType) - \(produce.quantityType)"
      chooseCategoryTextField.text = "\(produce.produceType)"
      
      quantityTextField.text = "\(produce.quantity)"
      priceUnitTextField.text = "\(produce.price)"
//      priceUnitLabel.text = "Price per \(produce.quantityType)"
//      priceUnitLabel.textColor = .black
//      descriptionTextField.text = "\(produce.description)"
//      descriptionTextView.text = "\(produce.description)"
      csDescriptionTextView.text = "\(produce.description)"
      
      tagsToDisplay = Produce.getTagNamesFrom(tags: produce.tags3)
      tagsToSave = produce.tags3
      
//      tagsSelected = produce.tags.map {
//        print($0)
//        return ($0.name, false, $0.priority, $0.key)
//      }
      
      DispatchQueue.main.async { [weak self] in
        self?.enableProcessButton()
        self?.tagsCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self?.tableView.reloadData()
        }
      }
    }
  }
  
  func firstCellTapped() {
    print("firstCellTapped")
    showPhotoOptionsView = false
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    let firstCellTapGesture = UITapGestureRecognizer(target: self, action: #selector(firstCellTapped))
    firstCellTapGesture.numberOfTapsRequired = 1
    firstCellTapGesture.numberOfTouchesRequired = 1
    
    firstCell.contentView.addGestureRecognizer(firstCellTapGesture)
    
//    firstCell.contentView.add
    
    isSeedTypeSelected = false
    isPlantTypeSelected = false
    isHarvestTypeSelected = false
    isOtherTypeSelected = false
    
    isFirstPhotoDeleteButtonHidden = true
    isSecondPhotoDeleteButtonHidden = true
    isThirdPhotoDeleteButtonHidden = true
    isFourthPhotoDeleteButtonHidden = true
    isFifthPhotoDeleteButtonHidden = true
    
    photoOptionsView.alpha = 0
    
//    if let currentProduceState = currentProduceState,
//      currentProduceState == ProduceState.archived.rawValue {
//      deletePictureButton.isEnabled = false
//      deletePictureButton.alpha = 0.5
//      
//      choosePictureButton.isEnabled = false
//      choosePictureButton.alpha = 0.5
//      
//      takePictureButton.isEnabled = false
//      takePictureButton.alpha = 0.5
//    } else {
//      deletePictureButton.isEnabled = true
//      deletePictureButton.alpha = 1
//      
//      choosePictureButton.isEnabled = true
//      choosePictureButton.alpha = 1
//      
//      takePictureButton.isEnabled = true
//      takePictureButton.alpha = 1
//    }
    
    stateLabelView.isHidden = true
    stateLabel.isHidden = true
    
    tagFontAttributes = [NSFontAttributeName: montserratFont!]
    
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
    
    tagsCollectionView.delegate = self
    tagsCollectionView.dataSource = self
    
//    deletePictureButton.isHidden = true
    
    categoriesTableViewDelegate = ProduceTypesDelegate(tableView: categoriesTableView)
    categoriesTableViewDelegate.setup()
    categoriesTableViewDelegate.didProduceTypeSelect = didCategorySelect
    
//    let produceImageOne = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
//    let produceImageTwo = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
//    let produceImageThree = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
//    let produceImageFour = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
//    let produceImageFive = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
//    
//    _ = produceImageOne.view
//    _ = produceImageTwo.view
//    _ = produceImageThree.view
//    _ = produceImageFour.view
//    _ = produceImageFive.view
    
//    produceImagesViewControllers.append(produceImageOne)
//    produceImagesViewControllers.append(produceImageTwo)
//    produceImagesViewControllers.append(produceImageThree)
//    produceImagesViewControllers.append(produceImageFour)
//    produceImagesViewControllers.append(produceImageFive)
    
    if let produceId = self.currentProduceId {
      Produce.getProduce(byProduceId: produceId, completion: { (produce) in
        SVProgressHUD.dismiss()
        self.currentProduce = produce
        
        self.loadProduceToUI(produce)
      })
    }
    
//    pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//    
//    pageContainer.setViewControllers([produceImageOne], direction: .forward, animated: true, completion: nil)
//    
//    pageContainer.dataSource = self
//    pageContainer.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    produceNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    chooseCategoryTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    unitTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    quantityTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    priceUnitTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
//    descriptionTextView.addBottomLine2(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
//    csDescriptionTextView.addLineToBottom()
    
    firstPhotoButton.makeMeBordered(cornerRadius: 4.0)
    secondPhotoButton.makeMeBordered(cornerRadius: 4.0)
    thirdPhotoButton.makeMeBordered(cornerRadius: 4.0)
    fourthPhotoButton.makeMeBordered(cornerRadius: 4.0)
    fifthPhotoButton.makeMeBordered(cornerRadius: 4.0)
    
    photoOptionsView.makeMeBordered(cornerRadius: 4.0)
    
    photoOptionsView.layer.shadowColor = UIColor.lightGray.cgColor
    photoOptionsView.layer.shadowOffset = CGSize(width: 0, height: 0)
    photoOptionsView.layer.shadowRadius = 3
    photoOptionsView.layer.shadowOpacity = 0.5
    
    
    stateLabelView.layer.borderColor = UIColor.black.cgColor
    stateLabelView.layer.masksToBounds = true
    stateLabelView.layer.borderWidth = 1.0
    stateLabelView.layer.cornerRadius = 3
  }
  
  func getProduceImageViewController(name: String) -> UIViewController {
    return UIStoryboard(name: "Produce", bundle: nil).instantiateViewController(withIdentifier: "\(name)")
  }
  
  @IBAction func nextButtonTouched(_ sender: AnyObject) {
    print("currentIndex: \(currentIndex)")
    if currentIndex < 4 {
      currentIndex += 1
      
      let vc = produceImagesViewControllers[currentIndex] as! ProduceImageVC
      
//      self.deletePictureButton.isHidden = !vc.containsCustomImage

//      pageContainer.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var number: ProducePhotoNumber?
    
    if let index = sender as? Int {
      switch index {
      case 0:
        number = .first
      case 1:
        number = .second
      case 2:
        number = .third
      case 3:
        number = .fourth
      case 4:
        number = .fifth
      default:
        break
      }
    }
    
    if segue.identifier == Storyboard.AddProduceChildToRetakeCamera {
      let vc = segue.destination as? CameraRetakeVC
      var image: UIImage?
      
      if let index = sender as? Int {
        let produceVC = produceImagesViewControllers[index] as? ProduceImageVC
        image = produceVC?.image
        
        vc?.image = image
        vc?.number = number
        vc?.pictureTaken = pictureTaken
      }
    } else if segue.identifier == Storyboard.AddProduceChildToCamera {
      let vc = segue.destination as? CameraVC

      vc?.pictureTaken = pictureTaken
      vc?.cancelled = cameraCancelled
      vc?.photoNumber = number
    } else if segue.identifier == Storyboard.AddProduceChildToChooseDetails {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? TagsListContainerVC
      vc?.tagsAlreadySelected = currentProduce?.tags3 ?? [String: Any]()
      vc?.tagsAlreadySelected = tagsToSave
      vc?.didSelectTags = didSelectTags
    } else if segue.identifier == Storyboard.AddProduceChildToChooseState {
      let vc = segue.destination as? ChooseStateVC
      vc?.didSelectState = didSelectState
    } else if segue.identifier == Storyboard.AddProduceChildToImageDetail {
      let vc = segue.destination as? ProduceImageZoomableVC
      vc?.customImage = sender as? UIImage
      vc?.hideCloseButton = false
    } else if segue.identifier == Storyboard.AddProduceChildToChooseUnit {
      let vc = segue.destination as? ChooseUnitVC
      vc?.didSelectUnit = didSelectUnit
      vc?.typeSelected = stateSelected
    }
  }
  
  func didSelectUnit(unit: String) {
    self.unitSelected = unit
    
    DispatchQueue.main.async { [weak self] in
      self?.unitTextField.text = unit
    }
  }
  
  func cameraCancelled() {
    showPhotoOptionsView = false
  }
  
  func didSelectState(state: String) {
    self.stateSelected = state
    self.unitSelected = nil
    self.unitTextField.text = ""
//    stateLabelView.isHidden = false
//    stateLabel.isHidden = false
//    
//    DispatchQueue.main.async { [weak self] in
//      self?.stateLabel.text = state
//      
//      self?.updateStateLabelSizeOnUI(state: state)
//    }
  }
  
  func updateStateLabelSizeOnUI(state: String) {
    let tagSize = (state as NSString).size(attributes: self.tagFontAttributes!)
    let size = CGSize(width: tagSize.width + 10, height: tagSize.height + 10)
    self.stateLabelViewConstraint.constant = size.width
    //      self?.stateLabel.frame.size = size
    
    self.tableView.reloadData()
  }
  
  func didSelectTags(_ tags: [String: Any]) {
    print(tags)
    tagsToSave = tags
    tagsToDisplay = Produce.getTagNamesFrom(tags: tags)
    print(tagsToDisplay)
//    tagsSelected = tags
//
    DispatchQueue.main.async { [weak self] in
      self?.tagsCollectionView.reloadData()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self?.tableView.reloadData()
      }
    }
  }
  
//  func getTagNamesFrom(tags: [String: Any]) -> [String] {
//    var tagNames = [String]()
//    
//    for (_, groupValue) in tags {
//      if let dictionaries = groupValue as? [String: Any] {
//        for (_, tagValue) in dictionaries {
//          if let tagValue = tagValue as? [String: Any],
//             let name = tagValue["name"] as? String
//          {
//            tagNames.append(name)
//          }
//        }
//      }
//    }
//    
//    return tagNames
//  }
  
  @IBAction func previousButtonTouched() {
    print("currentIndex: \(currentIndex)")
    if currentIndex > 0 {
      currentIndex -= 1
      let vc = produceImagesViewControllers[currentIndex] as! ProduceImageVC

//      self.deletePictureButton.isHidden = !vc.containsCustomImage
      
//      pageContainer.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
    }
  }
  
  // delete
  @IBAction func choosePictureButtonTouched() {
    changeTitleButton("SAVE")
    
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let imagePicker = UIImagePickerController()
      
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      
      present(imagePicker, animated: true, completion: nil)
    }
    
  }
  
  func areProduceImagesValid() throws {
    if
      !firstPhotoSaved &&
      !secondPhotoSaved &&
      !thirdPhotoSaved &&
      !fourthPhotoSaved &&
      !fifthPhotoSaved
    {
      throw ValidationFormError.error(Constants.ErrorMessages.imagesNotTaken)
    }
  }
  
  func getProduceCategory() throws -> (name: String, quantityType: String) {
    if let produceTypeSelected = produceTypeSelected {
      return produceTypeSelected
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.typeOfProduceNotProvided)
    }
  }
  
  func getUnitSelected() throws -> String {
    if let unitSelected = unitSelected {
      return unitSelected
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.unitNotSelected)
    }
  }

//  @IBOutlet weak var productNameTextField: UITextField!
//  @IBOutlet weak var chooseCategoryTextField: UITextField!
//  @IBOutlet weak var quantityTextField: UITextField!
//  @IBOutlet weak var priceUnitTextField: UITextField!
//  @IBOutlet weak var descriptionTextField: UITextField!

  func getQuantity() throws -> Int {
    let quantityText = quantityTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    let quantity = Int(quantityText)
    
    if let quantity = quantity {
      return quantity
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.quantityNotProvided)
    }
  }
  
  func getPrice() throws -> Double {
    let priceText = priceUnitTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    let price = Double(priceText)
    
    if let price = price {
      return price
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.priceNotProvided)
    }
  }
  
  func getDescription() throws -> String {
    let descriptionText = csDescriptionTextView.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    
    if descriptionText.characters.count > 0 {
      return descriptionText
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.descriptionNotProvided)
    }
  }
  
  @IBAction func deletePictureButtonTouched() {
    changeTitleButton("SAVE")
    
    let vc = produceImagesViewControllers[currentIndex] as! ProduceImageVC
    vc.image = nil
//    deletePictureButton.isHidden = true
    
    switch currentIndex {
    case 0:
      firstPhotoSaved = false
    case 1:
      secondPhotoSaved = false
    case 2:
      thirdPhotoSaved = false
    case 3:
      fourthPhotoSaved = false
    case 4:
      fifthPhotoSaved = false
    default:
      break
    }
  }
  
  // delete this code
  @IBAction func takePictureButtonTouched() {
    changeTitleButton("SAVE")
    var currentPhotoNumber: ProducePhotoNumber?
    
    switch currentIndex {
    case 0:
      if firstPhotoSaved {
        currentPhotoNumber = ProducePhotoNumber.first
      }
    case 1:
      if secondPhotoSaved {
        currentPhotoNumber = ProducePhotoNumber.second
      }
    case 2:
      if thirdPhotoSaved {
        currentPhotoNumber = ProducePhotoNumber.third
      }
    case 3:
      if fourthPhotoSaved {
        currentPhotoNumber = ProducePhotoNumber.fourth
      }
    case 4:
      if fifthPhotoSaved {
        currentPhotoNumber = ProducePhotoNumber.fifth
      }
    default:
      break
    }
    
    // old picture, wants to update it
    if let _ = currentPhotoNumber {
      performSegue(withIdentifier: Storyboard.AddProduceChildToRetakeCamera, sender: currentIndex)
    } else {// new picture
      performSegue(withIdentifier: Storyboard.AddProduceChildToCamera, sender: currentIndex)
    }
  }
  
  func animateForwardButton() {
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//      UIView.animate(
//        withDuration: 0.5,
//        delay: 0,
//        usingSpringWithDamping: 0.3,
//        initialSpringVelocity: 0.5,
//        options: [],
//        animations: {
//          self.nextButton.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
//        }, completion: { (finished) in
//          if finished {
//            DispatchQueue.main.async {
//              UIView.animate(withDuration: 0.3, animations: {
//                self.nextButton.transform = CGAffineTransform.identity
//              })
//            }
//          }
//      })
//    }
  }
  
  
  func pictureTaken(image: UIImage, number: ProducePhotoNumber) {
//    animateForwardButton()
//    deletePictureButton.isHidden = false
    showPhotoOptionsView = false
    
    switch number {
    case .first:
      firstPhotoSaved = true
      firstPhotoEdited = true
      currentIndex = 0
      firstPhotoButton.setImage(image, for: .normal)
      firstPhotoDeleteButton.isHidden = false
      isFirstPhotoDeleteButtonHidden = false
//      let viewController = produceImagesViewControllers[0] as? ProduceImageVC
//      viewController?.image = image
//      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .second:
      secondPhotoSaved = true
      secondPhotoEdited = true
      currentIndex = 1
      secondPhotoButton.setImage(image, for: .normal)
      secondPhotoDeleteButton.isHidden = false
      isSecondPhotoDeleteButtonHidden = false
//      let viewController = produceImagesViewControllers[1] as? ProduceImageVC
//      viewController?.image = image
//      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .third:
      thirdPhotoSaved = true
      thirdPhotoEdited = true
      currentIndex = 2
      thirdPhotoButton.setImage(image, for: .normal)
      isThirdPhotoDeleteButtonHidden = false
//      let viewController = produceImagesViewControllers[2] as? ProduceImageVC
//      viewController?.image = image
//      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .fourth:
      fourthPhotoSaved = true
      fourthPhotoEdited = true
      currentIndex = 3
      fourthPhotoButton.setImage(image, for: .normal)
      fourthPhotoDeleteButton.isHidden = false
      isFourthPhotoDeleteButtonHidden = false
//      let viewController = produceImagesViewControllers[3] as? ProduceImageVC
//      viewController?.image = image
//      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .fifth:
      fifthPhotoSaved = true
      fifthPhotoEdited = true
      currentIndex = 4
      fifthPhotoButton.setImage(image, for: .normal)
      fifthPhotoDeleteButton.isHidden = false
      isFifthPhotoDeleteButtonHidden = false
//      let viewController = produceImagesViewControllers[4] as? ProduceImageVC
//      viewController?.image = image
//      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    }
    
  }
  
  func pictureTaken2(image: UIImage) {
    if !firstPhotoSaved {

    } else if !secondPhotoSaved {

    } else if !thirdPhotoSaved {

    } else if !fourthPhotoSaved {

    } else if !fifthPhotoSaved {

    }
  }
  
  @IBAction func pickStateButtonTouched() {
    changeTitleButton("SAVE")
    showPhotoOptionsView = false
    performSegue(withIdentifier: Storyboard.AddProduceChildToChooseState, sender: nil)
  }
  
  
  @IBAction func pickProductsButtonTouched() {
    changeTitleButton("SAVE")
    showPhotoOptionsView = false
    performSegue(withIdentifier: Storyboard.AddProduceChildToChooseDetails, sender: nil)
  }  
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    if indexPath.row == 0 {
//      pageContainer.view.frame = cell.contentView.bounds
//      cell.contentView.insertSubview(pageContainer.view, at: 0)
//      cell.contentView.layoutIfNeeded()
    } else if indexPath.row == 6 {

      pickStateButton.layoutIfNeeded()

      
      shadowViewForPickStateButton.layoutIfNeeded()
      shadowViewForPickStateButton.makeMeBordered()
      
      shadowViewForPickStateButton.layer.shadowColor = UIColor.lightGray.cgColor
      shadowViewForPickStateButton.layer.shadowOffset = CGSize(width: 0, height: 0)
      shadowViewForPickStateButton.layer.shadowRadius = 3
      shadowViewForPickStateButton.layer.shadowOpacity = 0.5
    }else if indexPath.row == 7 {
      print(pickProductsButton.frame.size)
      pickProductsButton.layoutIfNeeded()
      print(pickProductsButton.frame.size)
      
      shadowViewForPickProductsButton.layoutIfNeeded()
      shadowViewForPickProductsButton.makeMeBordered()

      shadowViewForPickProductsButton.layer.shadowColor = UIColor.lightGray.cgColor
      shadowViewForPickProductsButton.layer.shadowOffset = CGSize(width: 0, height: 0)
      shadowViewForPickProductsButton.layer.shadowRadius = 3
      shadowViewForPickProductsButton.layer.shadowOpacity = 0.5
    }
    
  }
}

extension AddProduceChildVC {
  
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    showPhotoOptionsView = false
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    view.endEditing(true)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = super.tableView(tableView, heightForRowAt: indexPath)
    
    if indexPath.row == 2 {
      
      if thirdCellSelected {
        return 200
      } else {
        categoriesTableViewDelegate.clear()
        return thirdCellHeight
      }
    } else if indexPath.row == 6 {
      return 0
    } else if indexPath.row == 7 {
      tagsCollectionView.collectionViewLayout.invalidateLayout()
      tagsCollectionView.collectionViewLayout.prepare()
      print(tagsSelected.count)
      print(tagsCollectionView.collectionViewLayout.collectionViewContentSize.height + 100)
      return tagsCollectionView.collectionViewLayout.collectionViewContentSize.height + 100
    }
    
    return height
  }
  
}



extension AddProduceChildVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    pendingIndex = produceImagesViewControllers.index(of: pendingViewControllers.first!)!
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      currentIndex = pendingIndex
    }
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return produceImagesViewControllers.count
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let currentIndex = produceImagesViewControllers.index(of: viewController)
    
    if currentIndex == 0 {
      return nil
    }
    
    let previousIndex = abs((currentIndex! - 1) % produceImagesViewControllers.count)
    return produceImagesViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let currentIndex = produceImagesViewControllers.index(of: viewController)
    
    if currentIndex == (produceImagesViewControllers.count - 1) {
      return nil
    }
    
    let nextIndex = abs((currentIndex! + 1) % produceImagesViewControllers.count)
    return produceImagesViewControllers[nextIndex]
  }
}

extension AddProduceChildVC: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField === chooseCategoryTextField {
      let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
      produceTypeSelected = nil
      
      categoriesTableViewDelegate.filterProduces(byText: newString)
    }
    
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField === unitTextField {
      
      if let stateSelected = stateSelected {
        performSegue(withIdentifier: Storyboard.AddProduceChildToChooseUnit, sender: stateSelected)
      } else {
        let alert = UIAlertController(title: "Alert", message: "Please first, select a category", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
      }
      
      return false
    }
    
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
//    addItemButton.setTitle("EDIT", for: .normal)addItemButton.setTitle("EDIT", for: .normal)
    showPhotoOptionsView = false
    changeTitleButton("SAVE")
    if textField === chooseCategoryTextField {
//      tableView.scrollRectToVisible(categoriesTableView.frame, animated: true)
      textField.text = ""
      categoriesTableViewDelegate.filterProduces(byText: "")
      thirdCellSelected = true
      
      tableView.beginUpdates()
      tableView.endUpdates()
      
//      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//        let indexPath = IndexPath(row: 2, section: 0)
//        self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//      }
    }
    
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField === chooseCategoryTextField {
      if let produceType = produceTypeSelected {
        textField.text = "\(produceType.name)"
//        priceUnitLabel.text = "Price per \(produceType.quantityType)"
//        priceUnitLabel.textColor = .black        
      } else {
        textField.text = ""
      }
      
      thirdCellSelected = false

      UIView.animate(withDuration: 0.5, animations: {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.thirdCell.layoutIfNeeded()
      })
    }
  }
}

extension AddProduceChildVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage

    let deviceSize = UIScreen.main.bounds.size
    let resizedImage = chosenImage.resizeImage(withTargerSize: deviceSize)
    
    var currentPhotoNumber: ProducePhotoNumber?
    
    switch currentIndex {
    case 0:
      currentPhotoNumber = ProducePhotoNumber.first
    case 1:
      currentPhotoNumber = ProducePhotoNumber.second
    case 2:
      currentPhotoNumber = ProducePhotoNumber.third
    case 3:
      currentPhotoNumber = ProducePhotoNumber.fourth
    case 4:
      currentPhotoNumber = ProducePhotoNumber.fifth
    default:
      break
    }

    if let currentPhotoNumber = currentPhotoNumber {
//      deletePictureButton.isHidden = false
      animateForwardButton()
      
      switch currentPhotoNumber {
      case .first:
        firstPhotoSaved = true
        firstPhotoEdited = true
//        let viewController = produceImagesViewControllers[0] as? ProduceImageVC
//        viewController?.image = resizedImage
        DispatchQueue.main.async { [weak self] in
          self?.firstPhotoButton.setImage(resizedImage, for: .normal)
          self?.isFirstPhotoDeleteButtonHidden = false
        }
      case .second:
        secondPhotoSaved = true
        secondPhotoEdited = true
        DispatchQueue.main.async { [weak self] in
          self?.secondPhotoButton.setImage(resizedImage, for: .normal)
          self?.isSecondPhotoDeleteButtonHidden = false
        }
//        let viewController = produceImagesViewControllers[1] as? ProduceImageVC
//        viewController?.image = resizedImage
      case .third:
        thirdPhotoSaved = true
        thirdPhotoEdited = true
        DispatchQueue.main.async { [weak self] in
          self?.thirdPhotoButton.setImage(resizedImage, for: .normal)
          self?.isThirdPhotoDeleteButtonHidden = false
        }
//        let viewController = produceImagesViewControllers[2] as? ProduceImageVC
//        viewController?.image = resizedImage
      case .fourth:
        fourthPhotoSaved = true
        fourthPhotoEdited = true
        DispatchQueue.main.async { [weak self] in
          self?.fourthPhotoButton.setImage(resizedImage, for: .normal)
          self?.isFourthPhotoDeleteButtonHidden = false
        }
//        let viewController = produceImagesViewControllers[3] as? ProduceImageVC
//        viewController?.image = resizedImage
      case .fifth:
        fifthPhotoSaved = true
        fifthPhotoEdited = true
        DispatchQueue.main.async { [weak self] in
          self?.fifthPhotoButton.setImage(resizedImage, for: .normal)
          self?.isFifthPhotoDeleteButtonHidden = false
        }
//        let viewController = produceImagesViewControllers[4] as? ProduceImageVC
//        viewController?.image = resizedImage
      }
      
      DispatchQueue.main.async { [weak self] in
        self?.showPhotoOptionsView = false
      }
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

extension AddProduceChildVC: UITextViewDelegate {

  func textViewDidBeginEditing(_ textView: UITextView) {
    changeTitleButton("SAVE")
//    addItemButton.setTitle("EDIT", for: .normal)
  }
}

extension AddProduceChildVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////    return
//  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size: CGSize!
    
    let tag = tagsToDisplay[indexPath.row]
    let tagSize = (tag as NSString).size(attributes: self.tagFontAttributes!)
    size = CGSize(width: tagSize.width + 10, height: tagSize.height + 10)
    
    return size
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tagsToDisplay.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as! TagCell
    let tagSelected = tagsToDisplay[indexPath.row]
    
    cell.tagNameLabel.text = tagSelected
    
    return cell
  }
}




















































