//
//  ChooseDetailCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/17/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class ChooseDetailCell: UITableViewCell {
  
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var roundedView: UIView!
  static let cellId = "chooseDetailId"
  var hasAlreadyShadow = false
  @IBOutlet weak var tagNameLabel: UILabel!
  
  var priority = 0 {
    didSet{
      if priority == 0 {
        tagNameLabel.textColor = .black
      } else if priority == 1 {
        tagNameLabel.textColor = UIColor.hexStringToUIColor(hex: "#37d67c")
      }
    }
  }
  
  var name = "" {
    didSet {
      tagNameLabel.text = name
    }
  }
  
  var isCellSelected = false {
    didSet {
      if isCellSelected {

        roundedView.layer.borderColor = UIColor.red.cgColor

        iconImageView.image = UIImage(named: "icon-tag-selected")
      } else {
        iconImageView.image = UIImage(named: "icon-tag-not-selected")

        if !hasAlreadyShadow {
          
          roundedView.layer.borderWidth = 1
          roundedView.layer.cornerRadius = 5.0
          
          roundedView.layer.shadowColor = UIColor.black.cgColor
          roundedView.layer.shadowOffset = CGSize(width: 0, height: 0)
          roundedView.layer.shadowRadius = 7
          roundedView.layer.shadowOpacity = 0.2
        }
        
        roundedView.layer.borderColor = UIColor.clear.cgColor
      }
    }
  }
 
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectionStyle = .none
    tagNameLabel.text = ""
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.backgroundColor = .clear
    roundedView.backgroundColor = .white
    
  }
}














































