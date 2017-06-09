//
//  ItemCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/11/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
//  (produceId: String, whoseGarden: AddItemType, quantity: Int)
  
  var produceId: String?
  
  var dealState: DealState? {
    didSet {
      
      if isAnotherProduce {
        if let dealState = dealState {
          switch dealState {
          case .tradeDeleted:
            fallthrough
          case .tradeCancelled:
            fallthrough
          case .tradeCompleted:
            fallthrough
          case .tradeInProcess:
            fallthrough
          case .waitingAnswer:
            increaseQuantityDownButton.isHidden = true
            decreaseQuantityDownButton.isHidden = true
            
            increaseQuantityUpButton.isHidden = true
            decreaseQuantityUpButton.isHidden = true
            
            upPlusIcon.isHidden = true
            upMinusIcon.isHidden = true
            
            downPlusIcon.isHidden = true
            downMinusIcon.isHidden = true
          case .tradeRequest:
            break
//            increaseQuantityDownButton.isHidden = false
//            decreaseQuantityDownButton.isHidden = false
//            
//            downPlusIcon.isHidden = false
//            downMinusIcon.isHidden = false
          }
        } else {
          increaseQuantityDownButton.isHidden = false
          decreaseQuantityDownButton.isHidden = false
          
          downPlusIcon.isHidden = false
          downMinusIcon.isHidden = false
        }
      } else {
        if let dealState = dealState {
          switch dealState {
          case .tradeDeleted:
            fallthrough
          case .tradeCancelled:
            fallthrough
          case .tradeCompleted:
            fallthrough
          case .tradeInProcess:
            fallthrough
          case .waitingAnswer:
            increaseQuantityUpButton.isHidden = true
            decreaseQuantityUpButton.isHidden = true
            
            increaseQuantityDownButton.isHidden = true
            decreaseQuantityDownButton.isHidden = true
            
            downPlusIcon.isHidden = true
            downMinusIcon.isHidden = true
            
            upPlusIcon.isHidden = true
            upMinusIcon.isHidden = true
          case .tradeRequest:
            break
//            increaseQuantityUpButton.isHidden = false
//            decreaseQuantityUpButton.isHidden =  false
//            
//            upPlusIcon.isHidden = false
//            upMinusIcon.isHidden = false
          }
        } else {
          increaseQuantityUpButton.isHidden = true
          decreaseQuantityUpButton.isHidden = true
          
          upPlusIcon.isHidden = true
          upMinusIcon.isHidden = true
        }
      }
      
      
    }
  }
  
  var processQuantity: (String, Int, AddItemType, Int) -> Void = { _, _, _, _ in
  
  }
  
  var isMoneyCircle = false {
    didSet {
      if isMoneyCircle {
        itemImageView.image = UIImage(named: "money-circle-icon")
      }
    }
  }
  
  var isWorkerCircle = false {
    didSet {
      if isWorkerCircle {
        itemImageView.image = UIImage(named: "worker-circle-icon")
        if isAnotherProduce {
          increaseQuantityUpButton.isHidden = true
          decreaseQuantityUpButton.isHidden = true
          
          upPlusIcon.isHidden = true
          upMinusIcon.isHidden = true
        } else {
          increaseQuantityDownButton.isHidden = true
          decreaseQuantityDownButton.isHidden = true
          
          downPlusIcon.isHidden = true
          downMinusIcon.isHidden = true
        }
      } else {
        if isAnotherProduce {
          increaseQuantityUpButton.isHidden = false
          decreaseQuantityUpButton.isHidden = false
          
          upPlusIcon.isHidden = false
          upMinusIcon.isHidden = false
        } else {
          increaseQuantityDownButton.isHidden = false
          decreaseQuantityDownButton.isHidden = false
          
          downPlusIcon.isHidden = false
          downMinusIcon.isHidden = false
        }
      }
    }
  }
  
  var payWithWork = false {
    didSet {
      if isWorkerCircle {
        if payWithWork {
          itemImageView.alpha = 1
        } else {
          itemImageView.alpha = 0.5
        }
      } else {
        itemImageView.alpha = 1
      }
    }
  }
  
  var isAnotherProduce = false {
    didSet {
      if isAnotherProduce {
        increaseQuantityDownButton.isHidden = true
        decreaseQuantityDownButton.isHidden = true
        
        downPlusIcon.isHidden = true
        downMinusIcon.isHidden = true
      } else {
        increaseQuantityUpButton.isHidden = true
        decreaseQuantityUpButton.isHidden = true
        
        upPlusIcon.isHidden = true
        upMinusIcon.isHidden = true
      }
    }
  }
  
  
  @IBOutlet weak var downPlusIcon: UIImageView!
  @IBOutlet weak var upPlusIcon: UIImageView!
  @IBOutlet weak var upMinusIcon: UIImageView!
  @IBOutlet weak var downMinusIcon: UIImageView!
  
  @IBOutlet weak var decreaseQuantityUpButton: ButtonCircular!
  @IBOutlet weak var increaseQuantityUpButton: ButtonCircular!
  @IBOutlet weak var decreaseQuantityDownButton: ButtonCircular!
  @IBOutlet weak var increaseQuantityDownButton: ButtonCircular!
  
  @IBOutlet weak var itemImageView: UIImageViewCircular! {
    didSet {
      itemImageView.contentMode = .scaleAspectFill
    }
  }
  
  static let cellId = "itemCellId"
  
  var imageURLString: String? {
    didSet {
      if let url = URL(string: imageURLString ?? "") {
        hasContent = true
        itemImageView.sd_setImage(with: url)
      }
    }
  }
  
  var hasContent = false {
    didSet {
//      itemImageView.isHidden = !hasContent
//      print(itemImageView.isHidden)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
//    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
//    setup()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
//    circle(view: increaseQuantityUpButton, size: 20)
//    setup()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
//    setup()
  }
  
  
  @IBAction func increaseQuantityDownButtonTouched() {
    
    if let produceId = produceId {
      processQuantity(produceId, tag, .toMyGarden, 1)
    }
    
  }
  
  @IBAction func decreaseQuantityDownButtonTouched() {
    if let produceId = produceId {
      processQuantity(produceId, tag, .toMyGarden, -1)
    }
  }
  
  @IBAction func increaseQuantityUpButtonTouched() {
    if let produceId = produceId {
      processQuantity(produceId, tag, .toGardensAnother, 1)
    }
  }
  
  @IBAction func decreaseQuantityUpButtonTouched() {
    if let produceId = produceId {      
      processQuantity(produceId, tag, .toGardensAnother, -1)
    }
  }
  
  func setup() {
    
//    print(self.frame.size)
//    print(itemImageView.frame.size)
//    self.layoutIfNeeded()
//    self.itemImageView.layoutIfNeeded()
//    print(self.frame.size)
//    print(itemImageView.frame.size)
//    

    hasContent = false
    itemImageView.layer.cornerRadius = max(self.frame.size.width, self.frame.size.height) / 2
    itemImageView.layer.borderWidth = 1
    itemImageView.layer.borderColor = UIColor.clear.cgColor
    itemImageView.layer.masksToBounds = true
  }
}
























