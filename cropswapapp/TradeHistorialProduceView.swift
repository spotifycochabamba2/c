//
//  TradeHistorialProduceView.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

class TradeHistorialProduceView: UIView {
  @IBOutlet var contentView: UIView!
  
  @IBOutlet weak var produceImageView: UIImageViewCircular!
  @IBOutlet weak var produceNameLabel: UILabel!
  
  var producePictureURL: String? {
    didSet {
      if let url = URL(string: producePictureURL ?? "") {
        produceImageView.sd_setImage(with: url)
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setup()
  }
  
  public func setup() {
    Bundle.main.loadNibNamed("TradeHistorialProduceView", owner: self, options: nil)
    contentView.frame = self.bounds
    self.addSubview(contentView)
  }
}
