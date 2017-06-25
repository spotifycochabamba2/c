//
//  UserAnnotationView.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/19/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import Mapbox

public class UserAnnotationView: MGLAnnotationView {
  
//  var userImageView = UIImageView()
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
//    let frame = CGRect(x: center.x, y: center.y, width: 20, height: 20)
//    print(frame)
//    userImageView.frame = frame
    
    layer.cornerRadius = 80 / 2
    layer.borderWidth = 1
    layer.borderColor = UIColor.clear.cgColor
  }
  
  
  public override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
  

  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
//    print(frame)
//    userImageView.frame = frame
//    userImageView.backgroundColor = .yellow
//    userImageView.contentMode = .scaleAspectFill
////    userImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    addSubview(userImageView)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
