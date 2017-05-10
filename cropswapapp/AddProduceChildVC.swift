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
  
  @IBOutlet weak var stateLabelView: UIView!
  @IBOutlet weak var stateLabelViewConstraint: NSLayoutConstraint!
  let tagCellId = "TagCellId"
  
  var tagsSelected = [(String, Bool, Int, String)]()
  var stateSelected: String?
  
  @IBOutlet weak var stateLabel: UILabel!
  
//  @IBOutlet weak var stateCollectionView: TagsCollectionView!
  @IBOutlet weak var tagsCollectionView: TagsCollectionView!
  
  @IBOutlet weak var priceUnitLabel: UILabel!
  @IBOutlet weak var deletePictureButton: UIButton!
  
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
  var pageContainer: UIPageViewController!
  var currentIndex = 0
  var pendingIndex = 0
  var produceImagesViewControllers = [UIViewController]()
  
  var firstPhotoEdited = false
  var secondPhotoEdited = false
  var thirdPhotoEdited = false
  var fourthPhotoEdited = false
  var fifthPhotoEdited = false
  
  @IBOutlet weak var nextButton: UIButton!
  
  
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
  
  func getProduceImages() -> [UIImage] {
    var images = [UIImage]()
    
    if firstPhotoSaved {
      let vc = produceImagesViewControllers[0] as! ProduceImageVC
      images.append(vc.image!)
    }
    
    if secondPhotoSaved {
      let vc = produceImagesViewControllers[1] as! ProduceImageVC
      images.append(vc.image!)
    }
    
    if thirdPhotoSaved {
      let vc = produceImagesViewControllers[2] as! ProduceImageVC
      images.append(vc.image!)
    }
    
    if fourthPhotoSaved {
      let vc = produceImagesViewControllers[3] as! ProduceImageVC
      images.append(vc.image!)
    }
    
    if fifthPhotoSaved {
      let vc = produceImagesViewControllers[4] as! ProduceImageVC
      images.append(vc.image!)
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

    produceTypeSelected = produceType
    chooseCategoryTextField.text = produceType.name

    rootViewTapped()
  }
  
  func rootViewTapped() {
    view.endEditing(true)
  }
  
  func loadProduceToUI(_ produce: Produce?) {
    if let produce = produce {
      
      deletePictureButton.isHidden = false
      
      if let firstPicURL = produce.firstPictureURL {
        let vc = produceImagesViewControllers[0] as! ProduceImageVC
        vc.produceImageURL = firstPicURL
        firstPhotoSaved = true
      }
      
      if let secondPicURL = produce.secondPictureURL {
        let vc = produceImagesViewControllers[1] as! ProduceImageVC
        vc.produceImageURL = secondPicURL
        secondPhotoSaved = true
      }
      
      if let thirdPicURL = produce.thirdPictureURL {
        let vc = produceImagesViewControllers[2] as! ProduceImageVC
        vc.produceImageURL = thirdPicURL
        thirdPhotoSaved = true
      }
      
      if let fourthPicURL = produce.fourthPictureURL {
        let vc = produceImagesViewControllers[3] as! ProduceImageVC
        vc.produceImageURL = fourthPicURL
        fourthPhotoSaved = true
      }
      
      if let fifthPicURL = produce.fifthPictureURL {
        let vc = produceImagesViewControllers[4] as! ProduceImageVC
        vc.produceImageURL = fifthPicURL
        fifthPhotoSaved = true
      }
      
      didSelectState(state: produce.state)
//      stateSelected = produce.stat
      
      produceTypeSelected = (name: produce.produceType, quantityType: produce.quantityType)
      
      produceNameTextField.text = produce.name
//      chooseCategoryTextField.text = "\(produce.produceType) - \(produce.quantityType)"
      chooseCategoryTextField.text = "\(produce.produceType)"
      
      quantityTextField.text = "\(produce.quantity)"
      priceUnitTextField.text = "\(produce.price)"
      priceUnitLabel.text = "Price per \(produce.quantityType)"
      priceUnitLabel.textColor = .black
//      descriptionTextField.text = "\(produce.description)"
      descriptionTextView.text = "\(produce.description)"
      
      tagsSelected = produce.tags.map {
        print($0)
        return ($0.name, false, $0.priority, $0.key)
      }
      
      DispatchQueue.main.async { [weak self] in
        self?.tagsCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self?.tableView.reloadData()
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    stateLabelView.isHidden = true
    stateLabel.isHidden = true
    
    tagFontAttributes = [NSFontAttributeName: montserratFont!]
    
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
    
    tagsCollectionView.delegate = self
    tagsCollectionView.dataSource = self
    
//    stateCollectionView.delegate = self
//    stateCollectionView.dataSource = self
    
    descriptionTextView.delegate = self
    descriptionTextView.textContainer.maximumNumberOfLines = 4
    
    deletePictureButton.isHidden = true
    
    categoriesTableViewDelegate = ProduceTypesDelegate(tableView: categoriesTableView)
    categoriesTableViewDelegate.setup()
    categoriesTableViewDelegate.didProduceTypeSelect = didCategorySelect
    
    let produceImageOne = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
    let produceImageTwo = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
    let produceImageThree = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
    let produceImageFour = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
    let produceImageFive = self.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
    
    _ = produceImageOne.view
    _ = produceImageTwo.view
    _ = produceImageThree.view
    _ = produceImageFour.view
    _ = produceImageFive.view
    
    produceImagesViewControllers.append(produceImageOne)
    produceImagesViewControllers.append(produceImageTwo)
    produceImagesViewControllers.append(produceImageThree)
    produceImagesViewControllers.append(produceImageFour)
    produceImagesViewControllers.append(produceImageFive)
    
    if let produceId = self.currentProduceId {
      Produce.getProduce(byProduceId: produceId, completion: { (produce) in
        SVProgressHUD.dismiss()
        self.currentProduce = produce
        
        self.loadProduceToUI(produce)
      })
    }
    
    pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    pageContainer.setViewControllers([produceImageOne], direction: .forward, animated: true, completion: nil)
    
    pageContainer.dataSource = self
    pageContainer.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    produceNameTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    chooseCategoryTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    quantityTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    priceUnitTextField.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    descriptionTextView.addBottomLine(color: UIColor.hexStringToUIColor(hex: "#cdd1d7"))
    
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
      
      self.deletePictureButton.isHidden = !vc.containsCustomImage

      pageContainer.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
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
      vc?.photoNumber = number
    } else if segue.identifier == Storyboard.AddProduceChildToChooseDetails {
      let vc = segue.destination as? ChooseDetailVC
      vc?.didSelectTags = didSelectTags
    } else if segue.identifier == Storyboard.AddProduceChildToChooseState {
      let vc = segue.destination as? ChooseStateVC
      vc?.didSelectState = didSelectState
    }
  }
  
  func didSelectState(state: String) {
    self.stateSelected = state
    
    stateLabelView.isHidden = false
    stateLabel.isHidden = false
    
    DispatchQueue.main.async { [weak self] in
      self?.stateLabel.text = state
      
      self?.updateStateLabelSizeOnUI(state: state)
    }
  }
  
  func updateStateLabelSizeOnUI(state: String) {
    let tagSize = (state as NSString).size(attributes: self.tagFontAttributes!)
    let size = CGSize(width: tagSize.width + 10, height: tagSize.height + 10)
    self.stateLabelViewConstraint.constant = size.width
    //      self?.stateLabel.frame.size = size
    
    self.tableView.reloadData()
  }
  
  func didSelectTags(tags: [(String, Bool, Int, String)]) {
    tagsSelected = tags
    
    DispatchQueue.main.async { [weak self] in
      self?.tagsCollectionView.reloadData()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self?.tableView.reloadData()
      }
    }
  }
  
  @IBAction func previousButtonTouched() {
    print("currentIndex: \(currentIndex)")
    if currentIndex > 0 {
      currentIndex -= 1
      let vc = produceImagesViewControllers[currentIndex] as! ProduceImageVC

      self.deletePictureButton.isHidden = !vc.containsCustomImage
      
      pageContainer.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
    }
  }
  
  @IBAction func choosePictureButtonTouched() {
    
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
    let descriptionText = descriptionTextView.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    
    if descriptionText.characters.count > 0 {
      return descriptionText
    } else {
      throw ValidationFormError.error(Constants.ErrorMessages.descriptionNotProvided)
    }
  }
  
  @IBAction func deletePictureButtonTouched() {
    let vc = produceImagesViewControllers[currentIndex] as! ProduceImageVC
    vc.image = nil
    deletePictureButton.isHidden = true
    
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
  
  
  @IBAction func takePictureButtonTouched() {
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
    
//    if currentPhotoNumber == nil {
//      if !firstPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.first
//      } else if !secondPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.second
//      } else if !thirdPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.third
//      } else if !fourthPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.fourth
//      } else if !fifthPhotoSaved {
//        currentPhotoNumber = ProducePhotoNumber.fifth
//      }
//    }
    
    // old picture, wants to update it
    if let _ = currentPhotoNumber {
      performSegue(withIdentifier: Storyboard.AddProduceChildToRetakeCamera, sender: currentIndex)
    } else {// new picture
      performSegue(withIdentifier: Storyboard.AddProduceChildToCamera, sender: currentIndex)
    }
  }
  
  func animateForwardButton() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.3,
        initialSpringVelocity: 0.5,
        options: [],
        animations: {
          self.nextButton.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        }, completion: { (finished) in
          if finished {
            DispatchQueue.main.async {
              UIView.animate(withDuration: 0.3, animations: {
                self.nextButton.transform = CGAffineTransform.identity
              })
            }
          }
      })
      
//      UIView.animate(withDuration: 0.4, animations: {
//        self.nextButton.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
//      }) { (finished) in
//        UIView.animate(withDuration: 0.4, animations: {
//          self.nextButton.transform = CGAffineTransform.identity
//        })
//      }
    }
  }
  
  
  func pictureTaken(image: UIImage, number: ProducePhotoNumber) {
    animateForwardButton()
    deletePictureButton.isHidden = false
    
    switch number {
    case .first:
      firstPhotoSaved = true
      firstPhotoEdited = true
      currentIndex = 0
      let viewController = produceImagesViewControllers[0] as? ProduceImageVC
      viewController?.image = image
      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .second:
      secondPhotoSaved = true
      secondPhotoEdited = true
      currentIndex = 1
      let viewController = produceImagesViewControllers[1] as? ProduceImageVC
      viewController?.image = image
      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .third:
      thirdPhotoSaved = true
      thirdPhotoEdited = true
      currentIndex = 2
      let viewController = produceImagesViewControllers[2] as? ProduceImageVC
      viewController?.image = image
      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .fourth:
      fourthPhotoSaved = true
      fourthPhotoEdited = true
      currentIndex = 3
      let viewController = produceImagesViewControllers[3] as? ProduceImageVC
      viewController?.image = image
      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
      break
    case .fifth:
      fifthPhotoSaved = true
      fifthPhotoEdited = true
      currentIndex = 4
      let viewController = produceImagesViewControllers[4] as? ProduceImageVC
      viewController?.image = image
      pageContainer.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
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
    performSegue(withIdentifier: Storyboard.AddProduceChildToChooseState, sender: nil)
  }
  
  
  @IBAction func pickProductsButtonTouched() {
    performSegue(withIdentifier: Storyboard.AddProduceChildToChooseDetails, sender: nil)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    if indexPath.row == 0 {
      pageContainer.view.frame = cell.contentView.bounds
      cell.contentView.insertSubview(pageContainer.view, at: 0)
//      cell.contentView.layoutIfNeeded()
    } else if indexPath.row == 4 {

      pickStateButton.layoutIfNeeded()

      
      shadowViewForPickStateButton.layoutIfNeeded()
      shadowViewForPickStateButton.makeMeBordered()
      
      shadowViewForPickStateButton.layer.shadowColor = UIColor.lightGray.cgColor
      shadowViewForPickStateButton.layer.shadowOffset = CGSize(width: 0, height: 0)
      shadowViewForPickStateButton.layer.shadowRadius = 3
      shadowViewForPickStateButton.layer.shadowOpacity = 0.5
    }else if indexPath.row == 5 {
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
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = super.tableView(tableView, heightForRowAt: indexPath)
    
    if indexPath.row == 2 {
      
      if thirdCellSelected {
        return 200
      } else {
        return thirdCellHeight
      }

    } else if indexPath.row == 5 {
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
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    
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
        priceUnitLabel.text = "Price per \(produceType.quantityType)"
        priceUnitLabel.textColor = .black        
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
      deletePictureButton.isHidden = false
      animateForwardButton()
      
      switch currentPhotoNumber {
      case .first:
        firstPhotoSaved = true
        firstPhotoEdited = true
        let viewController = produceImagesViewControllers[0] as? ProduceImageVC
        viewController?.image = resizedImage
      case .second:
        secondPhotoSaved = true
        secondPhotoEdited = true
        let viewController = produceImagesViewControllers[1] as? ProduceImageVC
        viewController?.image = resizedImage
      case .third:
        thirdPhotoSaved = true
        thirdPhotoEdited = true
        let viewController = produceImagesViewControllers[2] as? ProduceImageVC
        viewController?.image = resizedImage
      case .fourth:
        fourthPhotoSaved = true
        fourthPhotoEdited = true
        let viewController = produceImagesViewControllers[3] as? ProduceImageVC
        viewController?.image = resizedImage
      case .fifth:
        fifthPhotoSaved = true
        fifthPhotoEdited = true
        let viewController = produceImagesViewControllers[4] as? ProduceImageVC
        viewController?.image = resizedImage
      }
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

extension AddProduceChildVC: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
    let newLines = text.components(separatedBy: CharacterSet.newlines)
    let linesAfterChange = existingLines.count + newLines.count - 1
    return linesAfterChange <= textView.textContainer.maximumNumberOfLines
  }
  
}

extension AddProduceChildVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////    return
//  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size: CGSize!
    
    let tag = tagsSelected[indexPath.row]
    let tagSize = (tag.0 as NSString).size(attributes: self.tagFontAttributes!)
    size = CGSize(width: tagSize.width + 10, height: tagSize.height + 10)
    
    return size
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tagsSelected.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as! TagCell
    let tagSelected = tagsSelected[indexPath.row]
    
    cell.tagNameLabel.text = tagSelected.0
    
    return cell
  }
}




















































