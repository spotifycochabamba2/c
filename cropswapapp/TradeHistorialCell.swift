//
//  TradeHistorialCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class TradeHistorialCell: UITableViewCell {
  static let cellId = "tradeHistorialCellId"
  
  var anotherUser: User? {
    didSet {
      if let anotherUser = anotherUser {
        anotherUsernameLabel.text = "\(anotherUser.name)'s List"
      }
    }
  }
  
  var dateCreated: Double? {
    didSet {
      if let dateCreated = dateCreated {
        let dateDouble = dateCreated * -1
        
        // put in utils struct
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        let dealDate = Date(timeIntervalSince1970: dateDouble)
        dateCreatedLabel.text = "\(formatter.string(from: dealDate))"
      }
    }
  }
  
  var myProduces = [(Produce, Int)]() {
    didSet {
      myProduces.forEach { produce in
        if produce.0.id == Constants.Ids.moneyId {
          addProduceToMyList(
            pictureURL: "",
            produceName: "Money",
            quantityType: "",
            quantity: produce.1,
            produceId: produce.0.id
          )
        } else if produce.0.id == Constants.Ids.workerId {
          addProduceToMyList(
            pictureURL: "",
            produceName: "Work",
            quantityType: "",
            quantity: produce.1,
            produceId: produce.0.id
          )
        } else {
          addProduceToMyList(
            pictureURL: produce.0.firstPictureURL,
            produceName: produce.0.name,
            quantityType: produce.0.quantityType,
            quantity: produce.1
          )
        }
      }
    }
  }
  
  var anotherProduces = [(Produce, Int)]() {
    didSet {
      anotherProduces.forEach { produce in
        if produce.0.id == Constants.Ids.moneyId {
          addProduceToAnothersList(
            pictureURL: "",
            produceName: "Money",
            quantityType: "",
            quantity: produce.1,
            produceId: produce.0.id
          )
        } else if produce.0.id == Constants.Ids.workerId {
          addProduceToAnothersList(
            pictureURL: "",
            produceName: "Work",
            quantityType: "",
            quantity: produce.1,
            produceId: produce.0.id
          )
        } else {
          addProduceToAnothersList(
            pictureURL: produce.0.firstPictureURL,
            produceName: produce.0.name,
            quantityType: produce.0.quantityType,
            quantity: produce.1
          )
        }
      }
    }
  }
  
  
  
  @IBOutlet weak var dateCreatedLabel: UILabel!
  @IBOutlet weak var anotherUsernameLabel: UILabel!
    
  @IBOutlet weak var baseStackView: UIStackView!
  @IBOutlet weak var anotherStackView: UIStackView!
  @IBOutlet weak var myStackView: UIStackView!
//  @IBOutlet weak var buttonsStackView: UIStackView!
//  @IBOutlet weak var finalizeTradeButton: UIButton!
//  @IBOutlet weak var makeOfferButton: UIButton!
//  @IBOutlet weak var cancelButton: UIButton!
  
//  @IBOutlet weak var finalizeTradeShadowView: UIView!
//  @IBOutlet weak var makeOfferShadowView: UIView!
//  @IBOutlet weak var cancelShadowView: UIView!
  
  var myViews = [UIView]()
  var anotherViews = [UIView]()
  
  var didMakeAnotherOffer: () -> Void = {}
  var didAcceptOffer: () -> Void = {}
  var didCancelOffer: () -> Void = {}
  
  func clearViews() {
    myViews.forEach {
      myStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
    anotherViews.forEach {
      anotherStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
    myViews.removeAll()
    anotherViews.removeAll()
  }
  
  func addProduceToMyList(pictureURL: String?, produceName: String, quantityType: String, quantity: Int, produceId: String = "") {
    let customView = TradeHistorialProduceView()
    customView.translatesAutoresizingMaskIntoConstraints = false
    
    if produceId == Constants.Ids.moneyId {
      customView.produceImageView.image = UIImage(named: "money-circle-icon")
      customView.produceNameLabel.text = "$\(quantity) \(produceName)"
    } else if produceId == Constants.Ids.workerId {
      customView.produceImageView.image = UIImage(named: "worker-circle-icon")
      customView.produceNameLabel.text = "Pay With Work"
    } else {
      customView.producePictureURL = pictureURL
      customView.produceNameLabel.text = "\(quantity) \(quantityType) \(produceName)"
    }

    
    
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
    view.addConstraint(heightConstraint)

    view.addSubview(customView)
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": customView]))
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": customView]))
    
    self.myStackView.addArrangedSubview(view)
    self.myViews.append(view)
  }
  
  func addProduceToAnothersList(pictureURL: String?, produceName: String, quantityType: String, quantity: Int, produceId: String = "") {
    let customView = TradeHistorialProduceView()
    customView.translatesAutoresizingMaskIntoConstraints = false
//    customView.producePictureURL = pictureURL
//    customView.produceNameLabel.text = "\(quantity) \(quantityType) \(produceName)"
    
    if produceId == Constants.Ids.moneyId {
      customView.produceImageView.image = UIImage(named: "money-circle-icon")
      customView.produceNameLabel.text = "$\(quantity) \(produceName)"
    } else if produceId == Constants.Ids.workerId {
      customView.produceImageView.image = UIImage(named: "worker-circle-icon")
      customView.produceNameLabel.text = "Pay With Work"
    } else {
      customView.producePictureURL = pictureURL
      customView.produceNameLabel.text = "\(quantity) \(quantityType) \(produceName)"
    }
    
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
    view.addConstraint(heightConstraint)

    view.addSubview(customView)
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": customView]))
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": customView]))
    
    self.anotherStackView.addArrangedSubview(view)
    self.anotherViews.append(view)
  }
  
  func processButtonViews(hidden: Bool) {
//    buttonsStackView.isHidden = hidden
//    finalizeTradeShadowView.isHidden = hidden
//    makeOfferShadowView.isHidden = hidden
//    cancelShadowView.isHidden = hidden
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
//    print(finalizeTradeButton.frame.size)
//    
//    finalizeTradeButton.makeMeBordered()
//    makeOfferButton.makeMeBordered()
//    cancelButton.makeMeBordered()
    
//    finalizeTradeShadowView.makeMeBordered()
//    finalizeTradeShadowView.layer.shadowColor = UIColor.lightGray.cgColor
//    finalizeTradeShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//    finalizeTradeShadowView.layer.shadowRadius = 3
//    finalizeTradeShadowView.layer.shadowOpacity = 0.5
//    
//    makeOfferShadowView.makeMeBordered()
//    makeOfferShadowView.layer.shadowColor = UIColor.lightGray.cgColor
//    makeOfferShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//    makeOfferShadowView.layer.shadowRadius = 3
//    makeOfferShadowView.layer.shadowOpacity = 0.5
//    
//    cancelShadowView.makeMeBordered()
//    cancelShadowView.layer.shadowColor = UIColor.lightGray.cgColor
//    cancelShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
//    cancelShadowView.layer.shadowRadius = 3
//    cancelShadowView.layer.shadowOpacity = 0.5
  }
  
//  @IBAction func finalizeTradeButtonTouched() {
//    didAcceptOffer()
//  }
//  
//  @IBAction func makeOfferButtonTouched() {
//    didMakeAnotherOffer()
//  }
//  
//  @IBAction func cancelButtonTouched() {
//    didCancelOffer()
//  }
  
  
}


















