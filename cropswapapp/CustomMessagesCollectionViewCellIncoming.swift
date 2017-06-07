//
//  File.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class CustomMessagesCollectionViewCellIncoming: JSQMessagesCollectionViewCell {
  
  @IBOutlet weak var customTextView: UITextView!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    //    self.messageBubbleTopLabel.textAlignment = NSTextAlignment.left
    //    self.cellBottomLabel.textAlignment = NSTextAlignment.left
  }
  
  override class func nib() -> UINib {
    return UINib(nibName: "CustomMessagesCollectionViewCellIncoming", bundle: nil)
  }
  
  override class func cellReuseIdentifier() -> String {
    return "CustomMessagesCollectionViewCellIncoming"
  }
}

