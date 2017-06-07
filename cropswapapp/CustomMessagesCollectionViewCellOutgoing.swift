//
//  CustomMessagesCollectionViewCellOutgoing.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//


import UIKit
import JSQMessagesViewController

class CustomMessagesCollectionViewCellOutgoing: JSQMessagesCollectionViewCell {
  override func awakeFromNib() {
    super.awakeFromNib()
    
    //    self.messageBubbleTopLabel.textAlignment = NSTextAlignment.right
    //    self.cellBottomLabel.textAlignment = NSTextAlignment.right
  }
  
  override class func nib() -> UINib {
    return UINib(nibName: "CustomMessagesCollectionViewCellOutgoing", bundle: nil)
  }
  
  override class func cellReuseIdentifier() -> String {
    return "CustomMessagesCollectionViewCellOutgoing"
  }
}
