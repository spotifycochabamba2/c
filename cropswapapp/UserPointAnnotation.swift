//
//  UserPointAnnotation.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/19/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Mapbox

public class UserPointAnnotation: NSObject, MGLAnnotation {
  
  public var coordinate: CLLocationCoordinate2D
  public var title: String?
  public var subtitle: String?
  
  var imageURL: String?
  var userName: String?
  var reuseIdentifier: String?
  
  init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
  }
}

//
//public class UserAnnotationView: NSObject, MGLAnnotationView {
//  
//}
