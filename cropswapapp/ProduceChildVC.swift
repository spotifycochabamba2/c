//
//  ProduceVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class ProduceChildVC: UITableViewController {
  
  @IBOutlet weak var relatedProducesCell: UITableViewCell!
  
  
  @IBOutlet weak var shadowView: UIView!
  
  @IBOutlet weak var gardenerLabel: UILabel! {
    didSet {
      gardenerLabel.text = ""
    }
  }
  
  @IBOutlet weak var addressGardenerLabel: UILabel! {
    didSet {
      addressGardenerLabel.text = ""
    }
  }
  
  @IBOutlet weak var descriptionProduceTextView: UITextView! {
    didSet {
      descriptionProduceTextView.text = ""
    }
  }
  
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var quantityAndTypeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  var producesRelatedFirstTimeLoaded = false
  
  var produceId: String?
  var ownerId: String?
  
  var numberFormatter = { () -> NumberFormatter in
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = "USD"
    
    return formatter
  }()
  
  
  var tags = [(name: String, priority: Int)]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.tagsCollectionView.reloadData()
        self?.tagsCollectionView.performBatchUpdates({
          }, completion: { (finished) in
            if finished {
              DispatchQueue.main.async {
                self?.tableView.reloadData()
              }
//              DispatchQueue.main.async { [weak self] in
//                let indexPath = IndexPath(row: 2, section: 0)
//                self?.tableView.reloadRows(at: [indexPath], with: .none)
//              }
            }
        })
      }
    }
  }
  
  var relatedProduces = [[String: Any]]() {
    didSet {
//      DispatchQueue.main.async { [weak self] in
        self.relatedProducesCollectionView.reloadData()
//      }
    }
  }
  
  func updateRelatedProducesOnUI(completion: @escaping () -> Void) {
    relatedProducesCollectionView.layoutIfNeeded()
    relatedProducesCollectionView.layoutSubviews()
    producesRelatedFirstTimeLoaded = false
    
    relatedProducesCollectionView.reloadData()
    relatedProducesCollectionView.performBatchUpdates({
      
    }, completion: { (finished) in
      if finished {
        completion()
      }
    })
  }
  

  
  let montserratFont = UIFont(name: "Montserrat-Regular", size: 9)
  var tagFontAttributes: [String: UIFont]?
  
  let tagCellId = "TagCellId"
  let relatedProducesCellId = "RelatedProducesCellId"
  
  var isFirstimeLoaded = true
  
  @IBOutlet weak var tagsCollectionView: TagsCollectionView!
  @IBOutlet weak var relatedProducesCollectionView: UICollectionView!

  
  var produce: Produce?
  
  // page container properties
  var pageContainer: UIPageViewController!
  var currentIndex = 0
  var pendingIndex = 0
  var produceImagesViewControllers = [UIViewController]()


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

//    relatedProducesCollectionView.collectionViewLayout.invalidateLayout()
//    relatedProducesCollectionView.collectionViewLayout.prepare()
//    relatedProducesCollectionView.layoutIfNeeded()
//    relatedProducesCollectionView.layoutSubviews()
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = UITableViewAutomaticDimension
    
    tagFontAttributes = [NSFontAttributeName: montserratFont!]
    
    tagsCollectionView.backgroundColor = .clear
    relatedProducesCollectionView.backgroundColor = .clear
    
    pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    tagsCollectionView.delegate = self
    tagsCollectionView.dataSource = self

    pageContainer.dataSource = self
    pageContainer.delegate = self
    
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }
    Ax.serial(tasks: [
      { [weak self] done in
        if
          let ownerId = self?.produce?.ownerId,
          let produceId = self?.produce?.id
        {
          
          User.getProducesByUser(byUserId: ownerId, completion: { [weak self] (dictionaries) in
            
            self?.relatedProduces = dictionaries.filter {
              let iteratedProduceId = $0["id"] as? String ?? ""
              
              return iteratedProduceId != produceId
            }
            
            done(nil)
            
//            self?.updateRelatedProducesOnUI {
//              done(nil)
//            }
          })
        } else {
          done(nil)
        }
      },
      
      { [weak self] done in
        if
          let produceId = self?.produce?.id
        {
          Produce.getProduce(byProduceId: produceId, completion: { [weak self] (produce) in
            self?.produce = produce
            done(nil)
          })
        } else {
          done(nil)
        }
      }
    ]) { [weak self] (error) in
      
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
      
      if let produce = self?.produce {
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//        DispatchQueue.main.async {
          self?.tags = produce.tags.map { return (name: $0.name, priority: $0.priority) }
//        }
        
        DispatchQueue.main.async {
          if let firstPictureURL = produce.firstPictureURL, firstPictureURL.characters.count > 0 {
            let produceImageOne = self?.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
            _ = produceImageOne.view
            
            produceImageOne.produceImageURL = firstPictureURL
            self?.produceImagesViewControllers.append(produceImageOne)
            
            self?.pageContainer.setViewControllers([produceImageOne], direction: .forward, animated: true, completion: nil)
          }
          
          if let secondPictureURL = produce.secondPictureURL, secondPictureURL.characters.count > 0 {
            let produceImageTwo = self?.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
            _ = produceImageTwo.view
            produceImageTwo.produceImageURL = secondPictureURL
            
            self?.produceImagesViewControllers.append(produceImageTwo)
          }
          
          if let thirdPictureURL = produce.thirdPictureURL, thirdPictureURL.characters.count > 0 {
            let produceImageThree = self?.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
            _ = produceImageThree.view
            produceImageThree.produceImageURL = thirdPictureURL
            
            self?.produceImagesViewControllers.append(produceImageThree)
          }
          
          if let fourthPictureURL = produce.fourthPictureURL, fourthPictureURL.characters.count > 0 {
            let produceImageFour = self?.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
            _ = produceImageFour.view
            
            produceImageFour.produceImageURL = fourthPictureURL
            
            self?.produceImagesViewControllers.append(produceImageFour)
          }
          
          if let fifthPictureURL = produce.fifthPictureURL, fifthPictureURL.characters.count > 0 {
            let produceImageFive = self?.getProduceImageViewController(name: "ProduceImageVC") as! ProduceImageVC
            _ = produceImageFive.view
            produceImageFive.produceImageURL = fifthPictureURL
            
            self?.produceImagesViewControllers.append(produceImageFive)
          }
          
          
          self?.gardenerLabel.text = "\(produce.ownerUsername)'s Garden"
          self?.descriptionProduceTextView.text = produce.description
          
          self?.categoryLabel.text = produce.produceType
          self?.quantityAndTypeLabel.text = "\(produce.quantity) \(produce.quantityType)"
          self?.priceLabel.text = self?.numberFormatter.string(from: NSNumber(value: produce.price))
        }
      }

    }
  }
  
  
  @IBAction func rightButtonTouched() {
    if currentIndex < (produceImagesViewControllers.count - 1) {
      currentIndex += 1
      pageContainer.setViewControllers([produceImagesViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
    }
  }
  
  
  @IBAction func leftButtonTouched(_ sender: AnyObject) {
    if currentIndex > 0 {
      currentIndex -= 1
      pageContainer.setViewControllers([produceImagesViewControllers[currentIndex]], direction: .reverse, animated: true, completion: nil)
    }
  }
  

  
  func getProduceImageViewController(name: String) -> UIViewController {
    return UIStoryboard(name: "Produce", bundle: nil).instantiateViewController(withIdentifier: "\(name)")
  }
}



extension ProduceChildVC {
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      if isFirstimeLoaded {
        pageContainer.view.frame = cell.contentView.bounds
        cell.contentView.insertSubview(pageContainer.view, at: 0)
        cell.contentView.layoutIfNeeded()
        
        let shadowLayer = CALayer()
        shadowLayer.frame = CGRect(x: 0, y: shadowView.frame.size.height, width: shadowView.frame.size.width, height: 70)
        shadowLayer.backgroundColor = UIColor.white.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowRadius = 12
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowOffset = CGSize(width: 0, height: -60)
        
        shadowView.layer.addSublayer(shadowLayer)
        
        isFirstimeLoaded = false
      }
    } else if indexPath.row == 4 {
      print(" willDisplay picky frame: \(relatedProducesCollectionView.frame)")
      print(" willDisplay picky bounds: \(relatedProducesCollectionView.bounds)")
    } else if indexPath.row == 1 {

    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let height = super.tableView(tableView, heightForRowAt: indexPath)
    
    if indexPath.row == 1 {
      print("dalmata from heightForRowAt descriptionProduceTextView.frame.size.height: \(descriptionProduceTextView.frame.size.height)")
      return descriptionProduceTextView.frame.size.height + 54 + 13 + 50
    } else if indexPath.row == 2 {
      if tags.count > 0  {
        tagsCollectionView.collectionViewLayout.invalidateLayout()
        tagsCollectionView.collectionViewLayout.prepare()
        tagsCollectionView.layoutIfNeeded()
        tagsCollectionView.layoutSubviews()
        
        return tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
      } else {
        return 0
      }
    } else if indexPath.row == 4 {
      if relatedProduces.count > 0 {
        relatedProducesCollectionView.collectionViewLayout.invalidateLayout()
        relatedProducesCollectionView.collectionViewLayout.prepare()
        relatedProducesCollectionView.layoutIfNeeded()
        relatedProducesCollectionView.layoutSubviews()
        print(" heightForRowAt picky frame: \(relatedProducesCollectionView.frame)")
        print(" heightForRowAt picky bounds: \(relatedProducesCollectionView.bounds)")
        return relatedProducesCollectionView.collectionViewLayout.collectionViewContentSize.height
      } else {
        return 0
      }
    }
    
    return height
  }
}

extension ProduceChildVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView === tagsCollectionView {
      return tags.count
    } else {
      return relatedProduces.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: UICollectionViewCell!
    
    if collectionView === tagsCollectionView {
      let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as! TagCell
      let tag = tags[indexPath.row]
      tagCell.tagNameLabel.text = tag.name
      
      cell = tagCell
    } else {
      let relatedProduceCell = collectionView.dequeueReusableCell(withReuseIdentifier: relatedProducesCellId, for: indexPath) as! RelatedProduceCell
      print(indexPath.row)
      let relatedProduce = relatedProduces[indexPath.row]
      let picURL = relatedProduce["firstPictureURL"] as? String
      
      relatedProduceCell.imageURL = picURL
      cell = relatedProduceCell
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size: CGSize!
    
    if collectionView === tagsCollectionView {
      let tag = tags[indexPath.row]
      let tagSize = (tag.name as NSString).size(attributes: self.tagFontAttributes!)
      size = CGSize(width: tagSize.width + 10, height: tagSize.height + 10)
    } else {
      size = CGSize(width: 60, height: 60)
    }
    
    return size
  }
  
}


extension ProduceChildVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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





















