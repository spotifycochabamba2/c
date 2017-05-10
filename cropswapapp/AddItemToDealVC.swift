//
//  AddItemToDealVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/12/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddItemToDealVC: UIViewController {
  
  var ownerUsername : String?
  var ownerId: String?
  var whoseGarden: AddItemType?
  var produces = [[String: Any]]()
  var producesAlreadySelected = [Produce]()
  
  var itemDidAdd: (Produce, AddItemType) -> Void = { _, _ in }
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  @IBOutlet weak var deleteButton: UIButton!
  
  @IBOutlet weak var gardenTitleLabel: UILabel!
  @IBOutlet weak var produceImageView: UIImageView!
  @IBOutlet weak var produceNameLabel: UILabel!
  @IBOutlet weak var quantityLabel: UILabel!
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    SVProgressHUD.dismiss()
  }
  
  @IBAction func addQuantityButtonTouched() {
    
  }
  
  @IBAction func subtrackButtonTouched() {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    deleteButton.isHidden = true
    
    print(ownerId)
    print(whoseGarden)
    
    if let ownerId = ownerId {
      
      SVProgressHUD.show()
      User.getProducesByUser(byUserId: ownerId, completion: { [weak self] (newProduces) in
        SVProgressHUD.dismiss()
        if let this = self {
          print(newProduces.count)
          this.produces = this.filter(produces: newProduces, by: this.producesAlreadySelected)
          print(this.produces.count)
          
          if this.produces.count > 0 {
            this.loadOneProduceToUI(this.produces[0])
          } else {
            // show an alter to go back since no more items exist to work with
          }
        }
      })
      
    }
    
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
  }
  
  func loadOneProduceToUI(_ produce: [String: Any]) {
    if let whoseGarden = whoseGarden {
      switch whoseGarden {
      case .toGardensAnother:
        gardenTitleLabel.text = "\(ownerUsername?.capitalized ?? "Someone")'s Garden"
        
      case .toMyGarden:
        gardenTitleLabel.text = "My Garden"
      }
    }
  }
  
  func filter(produces: [[String: Any]], by: [Produce]) -> [[String: Any]] {
//    self.produces = dictionaries.filter {
//      let iteratedProduceId = $0["id"] as? String ?? ""
//      return iteratedProduceId != produceId
//    }
    return produces.filter { item in
      let produceId = item["id"] as? String ?? ""
//      false to filter
      return !by.contains(where: { (produce) -> Bool in
        return produce.id == produceId
      })
    }
  }
  
  @IBAction func nextProduce() {
    
  }
  
  @IBAction func previousProduce() {
    
  }
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true)
  }
  @IBAction func acceptButtonTouched() {
    
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
  }
}

































