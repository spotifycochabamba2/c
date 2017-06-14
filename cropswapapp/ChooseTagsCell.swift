//
//  ChooseTagsCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/13/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class ChooseTagsCell: UITableViewCell {
  @IBOutlet weak var checkmarkButton: UIButton! {
    didSet {
      checkmarkButton.isUserInteractionEnabled = false
    }
  }
  @IBOutlet weak var tagNameLabel: UILabel!
  
  static let identifier = "chooseTagsCellId"
  
  var currentTag: [String: Any]? {
    didSet {
      if let currentTag = currentTag {
        name = currentTag["name"] as? String
      }
    }
  }
  
  var isChecked = false {
    didSet {
      if isChecked {
        checkmarkButton.setImage(UIImage(named: "tag-check-active"), for: .normal)
      } else {
        checkmarkButton.setImage(UIImage(named: "tag-check-inactive"), for: .normal)
      }
    }
  }
  
  var name: String? {
    didSet {
      tagNameLabel.text = name
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    name = ""
    isChecked = false
  }
}
