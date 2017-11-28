//
//  FeedMapVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/15/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import Ax
import SVProgressHUD
import Mapbox

public class FeedMapVC: UIViewController {
  var lat = Constants.Map.unitedStatesLat
  var lng = Constants.Map.unitedStatesLng
  var radiusInMiles = 0
  var enabledRadiusFilter = false
  var mapView: MGLMapView!
  var currentZoomLevel: Double = 12.0
  
  var currentUser: User?
  
  var userIcon = UIImage(named: "home-tabbar-icon-active")!
  
  let shapeSourceId = "cropswap-users"
  let cropswapIconsId = "cropswap-icons"
  let circlesIconsId = "clustered-users"
  let numbersLayerId = "clustered-numbers"
  let cropswapUserNamesId = "cropswap-user-names"
  
  var shapeSource: MGLShapeSource?
  var featureUsers: [MGLPointFeature]?
  
  @IBOutlet weak var currentLocationButton: UIButton!
  
  public func didSelectDistance(_ distance: Int) {
    SVProgressHUD.show()
    radiusInMiles = distance
    
    enabledRadiusFilter = distance > 0
    
    loadUsers(
      latitude: lat,
      longitude: lng,
      radius: radiusInMiles
    ) {
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
    }
  }
  
  @IBAction func currentLocationButtonTouched() {
    let location = CLLocationCoordinate2DMake(lat, lng)
    
    mapView.setCenter(location, zoomLevel: 12.0, animated: true)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    mapView.logoView.alpha = 0
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    SVProgressHUD.show()
    
//    let url = MGLStyle.darkStyleURL(withVersion: 9)
    let url = URL(string: "mapbox://styles/cropswapapp/cj8rc8jc8bb3o2rpjp5rx7rcj")
    mapView = MGLMapView.init(frame: view.bounds, styleURL: url)
    
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    mapView.delegate = self
    mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:))))
    
    view.addSubview(mapView)
    view.bringSubview(toFront: currentLocationButton)
    
//    loadUsers(
//      latitude: lat,
//      longitude: lng,
//      radius: radiusInMiles
//    ) {
//      DispatchQueue.main.async {
//        SVProgressHUD.dismiss()
//      }
//    }
    
    User.listenChangesOnUsers { [weak self] userChanged in
      guard let this = self else { return }
      
      guard
        let currentUserId = this.currentUser?.id,
        let userChangedId = userChanged.id,
        currentUserId != userChangedId
      else {
        return
      }
      
      let produceCount = userChanged.produceCount ?? 0
      
      let feature = this.getFeatureBy(userId: userChangedId)
      
      if produceCount > 0 {
        if feature == nil {
          if let newFeature = this.createFeatureUser(user: userChanged) {
            this.featureUsers?.append(newFeature)
            _ = this.addFeaturesToMap(this.featureUsers ?? [])
          }
        }
      } else {
        if let feature = feature {
          let index = this.featureUsers?.index(where: { (currentFeature) -> Bool in
            if
              let currentUserId = currentFeature.attributes["id"] as? String,
              let userId = feature.attributes["id"] as? String
            {
              return currentUserId == userId
            }
            
            return false
          })
          
          if let index = index {
            this.featureUsers?.remove(at: index)
            _ = this.addFeaturesToMap(this.featureUsers ?? [])
          }
        }
      }
    }
  }
  
  public func createUserPointAnnotation(
    userId: String,
    userName: String,
    latitude: Double,
    longitude: Double,
    pictureURLString: String
  ) -> UserPointAnnotation {
    let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    
    let point = UserPointAnnotation(
      coordinate: coordinate,
      title: userName,
      subtitle: ""
    )
    
    point.userName = userName
    point.imageURL = pictureURLString
    point.reuseIdentifier = userId

    return point
  }
  
  public func getAnnotationBy( annotationId: String) -> UserPointAnnotation? {
    guard !annotationId.isEmpty else {
      return nil
    }
    
    let annotation = mapView?.annotations?.first {
      let userPointAnnotation = $0 as? UserPointAnnotation
      var id = userPointAnnotation?.reuseIdentifier ?? ""
      id = id.trimmingCharacters(in: CharacterSet.whitespaces)
      
      if id.isEmpty {
        return false
      }
      
      return id == annotationId
    }
    
    return annotation as? UserPointAnnotation
  }
  
  func getFeatureBy(userId: String) -> MGLPointFeature? {
    if userId.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
      return nil
    }
    
    return featureUsers?.first {
      let currentUserId = $0.attributes["id"] as? String ?? ""
      
      return userId == currentUserId
    }
  }
  
  public func loadUsers(
    latitude: Double! = nil,
    longitude: Double! = nil,
    radius: Int,
    completion: @escaping() -> Void
  ) {
    
    if let annotations = mapView.annotations {
      mapView.removeAnnotations(annotations)
    }
    
    Ax.serial(tasks: [
      { [weak self] done in
//        if radius > 0 {
          User.getUser(byUserId: User.currentUser?.uid, completion: { (result) in
            if let this = self {
              switch result {
              case .success(let user):
                this.currentUser = user
                
                if let latitude = user.latitude,
                  let longitude = user.longitude
                {
                  this.lat = latitude
                  this.lng = longitude
                  let location = CLLocationCoordinate2DMake(latitude, longitude)
                  
                  DispatchQueue.main.async {
                    this.mapView.setCenter(location, zoomLevel: this.currentZoomLevel, animated: false)
                  }
                }
                
                this.radiusInMiles = radius
                
//                if let radius = user.radiusFilterInMiles {
//                  if user.enabledRadiusFilter ?? true {
//                    this.radiusInMiles = radius
//                    this.enabledRadiusFilter = true
//                  } else {
//                    this.radiusInMiles = 0
//                    this.enabledRadiusFilter = false
//                  }
//                }
              case .fail(let error):
                break
              }
            }
            
            done(nil)
          })
//        }else {
//          done(nil)
//        }
      },
      
      { [weak self] done in
        guard let this = self else {
          done(nil)
          return
        }
        
        var radius = 0
        
        if this.enabledRadiusFilter {
          radius = this.radiusInMiles
        }
        
        User.getUsersBy(
          latitude: this.lat,
          longitude: this.lng,
          radius: radius,
          completion: { [weak self] (users) in
            guard let this = self else { return }
            
            let result = this.addFeaturesToMap(
              this.convertUsersToFeatures(
                users,
                includesCurrentUser: this.currentUser
              )
            )
            
            this.shapeSource = result?.source
            this.featureUsers = result?.features
            
//            var pointAnnotations = [UserPointAnnotation]()
//            let currentUserId = self?.currentUser?.id
//            
//            users.forEach {
//              let user = $0
//              
//              let urlString = user["profilePictureURL"] as? String
//              let name = user["name"] as? String
//              let location = user["_geoloc"] as? [String: Any]
//              let id = user["objectID"] as? String
//              
//              if
//                id != nil && currentUserId != nil &&
//                !listContainsCurrentUser && id == currentUserId
//              {
//                listContainsCurrentUser = true
//              }
//              
//              if let lat = location?["lat"] as? Double,
//                let lng = location?["lng"] as? Double
//              {
//                let coordinate = CLLocationCoordinate2DMake(lat, lng)
//                
//                let point = UserPointAnnotation(
//                  coordinate: coordinate,
//                  title: name,
//                  subtitle: ""
//                )
//                
//                point.userName = name
//                point.imageURL = urlString
//                point.reuseIdentifier = id
//                
//                pointAnnotations.append(point)
//              }
//            }
//            
//            if !listContainsCurrentUser {
//              if
//                let userName = this.currentUser?.name,
//                let userId = this.currentUser?.id,
//                let latitude = this.currentUser?.latitude,
//                let longitude = this.currentUser?.longitude,
//                let pictureURLString = this.currentUser?.profilePictureURL
//              {
//                let newAnnotation = this.createUserPointAnnotation(
//                  userId: userId,
//                  userName: userName,
//                  latitude: latitude,
//                  longitude: longitude,
//                  pictureURLString: pictureURLString
//                )
//                
//                DispatchQueue.main.async {
//                  this.mapView.addAnnotation(newAnnotation)
//                }
//              }
//            }
//            
//            DispatchQueue.main.async {
//              self?.mapView.addAnnotations(pointAnnotations)
//            }
            
            done(nil)
          })
      }
      
    ]) { (error) in
      completion()
    }
  }
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.MapToProfileChild {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProfileContainerVC
      
      let attributes = sender as! [String: Any]
      
      if
        let userId = attributes["id"] as? String,
        let userName = attributes["name"] as? String
      {
        vc?.currentUserId = userId
        vc?.currentUsername = userName
        vc?.showBackButton = true
      }
      
//      let userAnnotation = sender as! UserPointAnnotation
//      
//      vc?.currentUserId = userAnnotation.reuseIdentifier
//      vc?.currentUsername = userAnnotation.userName
//      vc?.showBackButton = true
    }
  }
  
  func createUserFeature(json: [String: Any]) -> MGLPointFeature? {
    let name = json["name"] as? String
    let id = json["objectID"] as? String
    let location = json["_geoloc"] as? [String: Any]
    let stringURL = json["profilePictureURL"] as? String
    
    if
      let lat = location?["lat"] as? Double,
      let lng = location?["lng"] as? Double
    {
      let coordinate = CLLocationCoordinate2D(
        latitude: lat,
        longitude: lng
      )
      
      let feature = MGLPointFeature()
      feature.coordinate = coordinate
      
      var attributes = [String: Any]()
      attributes["name"] = name
      attributes["id"] = id
      attributes["stringURL"] = stringURL
      
      feature.attributes = attributes
      
      return feature
    }

    return nil
  }
  
  func addFeaturesToMap(
    _ featureUsers: [MGLPointFeature]
  ) -> (source: MGLShapeSource, features: [MGLPointFeature])? {
    guard let style = mapView.style else { return nil }
    
    style.setImage(
      UIImage(named: "home-tabbar-icon-active")!,
      forName: "cropswap-user"
    )

    let sourceCreated = MGLShapeSource(
      identifier: shapeSourceId,
      features: featureUsers,
      options: [
        .clustered: true,
        .clusterRadius: userIcon.size.width
      ]
    )
    
    let cropswapIcons = MGLSymbolStyleLayer(
      identifier: cropswapIconsId,
      source: sourceCreated
    )

    cropswapIcons.iconImageName = MGLStyleValue.init(rawValue: "cropswap-user")
    cropswapIcons.iconAllowsOverlap = MGLStyleValue(rawValue: true)
    cropswapIcons.textColor = MGLStyleValue(rawValue: UIColor.black)
    cropswapIcons.text = MGLStyleValue(rawValue: "{name}")
    cropswapIcons.textTranslation = MGLStyleValue(rawValue: NSValue(cgVector: CGVector(dx: 0, dy: 20)))
    cropswapIcons.predicate = NSPredicate(format: "%K != YES", "cluster")
    cropswapIcons.textAllowsOverlap = MGLStyleValue(rawValue: true)
    
    
    let circlesLayer = MGLCircleStyleLayer(
      identifier: circlesIconsId,
      source: sourceCreated
    )
    circlesLayer.circleRadius = MGLStyleValue(
      rawValue: NSNumber(value: Double(userIcon.size.width) / 2)
    )
    circlesLayer.circleOpacity = MGLStyleValue.init(rawValue: 0.75)
    circlesLayer.circleStrokeColor = MGLStyleValue(rawValue: UIColor.hexStringToUIColor(hex: "#31D071").withAlphaComponent(0.75))
    circlesLayer.circleStrokeWidth = MGLStyleValue(rawValue: 2)
    circlesLayer.circleColor = MGLStyleValue(rawValue: UIColor.lightGray)
    circlesLayer.predicate = NSPredicate(format: "%K == YES", "cluster")
    
    
    let numbersLayer = MGLSymbolStyleLayer(
      identifier: numbersLayerId,
      source: sourceCreated
    )
    numbersLayer.textColor = MGLStyleValue(rawValue: UIColor.white)
    numbersLayer.textFontSize = MGLStyleValue(rawValue: NSNumber(value: Double(userIcon.size.width) / 2))
    numbersLayer.iconAllowsOverlap = MGLStyleValue(rawValue: true)
    numbersLayer.text = MGLStyleValue(rawValue: "{point_count}")
    numbersLayer.predicate = NSPredicate(format: "%K == YES", "cluster")
    
    DispatchQueue.main.async {
      
      if let sourceTmp = style.source(withIdentifier: self.shapeSourceId) {
        style.removeSource(sourceTmp)
      }
      
      style.addSource(sourceCreated)
      
      if let layer = style.layer(withIdentifier: self.cropswapIconsId) {
        style.removeLayer(layer)
      }
      style.addLayer(cropswapIcons)
      
      if let layer = style.layer(withIdentifier: self.circlesIconsId) {
        style.removeLayer(layer)
      }
      style.addLayer(circlesLayer)
      
      if let layer = style.layer(withIdentifier: self.numbersLayerId) {
        style.removeLayer(layer)
      }
      style.addLayer(numbersLayer)
    }
    
    return (source: sourceCreated, features: featureUsers)
  }
  
  func convertUsersToFeatures(
    _ users: [[String: Any]],
    includesCurrentUser currentUser: User?
  ) -> [MGLPointFeature] {
    var listContainsCurrentUser = false
    
    var featureUsers = users.flatMap { user -> MGLPointFeature? in
      let id = user["objectID"] as? String
      
      if
        let id = id,
        let currentUserId = currentUser?.id,
        !listContainsCurrentUser,
        id == currentUserId
      {
        listContainsCurrentUser = true
      }
      
      return createUserFeature(json: user)
    }
    
    
    if !listContainsCurrentUser {
      if let featureUser = createFeatureUser(user: currentUser) {
        featureUsers.append(featureUser)
      }
    }
    
    return featureUsers
  }
  
  func createFeatureUser(user: User?) -> MGLPointFeature? {
    if
      let userName = user?.name,
      let userId = user?.id,
      let latitude = user?.latitude,
      let longitude = user?.longitude
//      let pictureURLString = user?.profilePictureURL
    {
      let coordinate = CLLocationCoordinate2D(
        latitude: latitude,
        longitude: longitude
      )
      
      let feature = MGLPointFeature()
      feature.coordinate = coordinate
      
      var attributes = [String: Any]()
      attributes["name"] = userName
      attributes["id"] = userId
      attributes["stringURL"] = user?.profilePictureURL
      
      feature.attributes = attributes
      
      return feature
    }
    
    return nil
  }
}

extension FeedMapVC: MGLMapViewDelegate {
  
  @objc func handleMapTap(sender: UITapGestureRecognizer) {
    
    if sender.state == .ended {
      
      let layerIdentifiers: Set = [cropswapIconsId]
      
      let point = sender.location(in: sender.view!)
      
      for f
      in mapView.visibleFeatures(at: point, styleLayerIdentifiers: layerIdentifiers)
      where f is MGLPointFeature
      {
        showCallout(feature: f as! MGLPointFeature)
        return
      }
      
      let touchCoordinate = mapView.convert(point, toCoordinateFrom: sender.view!)
      let touchLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
      
      let touchRect = CGRect(origin: point, size: .zero).insetBy(dx: -22.0, dy: -22.0)
      let possibleFeatures = mapView.visibleFeatures(in: touchRect, styleLayerIdentifiers: Set(layerIdentifiers)).filter { $0 is MGLPointFeature }
      
      let closestFeatures = possibleFeatures.sorted(by: {
        return CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude).distance(from: touchLocation)
                <
          CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude).distance(from: touchLocation)
      })
      
      if let f = closestFeatures.first {
        showCallout(feature: f as! MGLPointFeature)
      }
      
      mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
    }
    
  }
  
  func showCallout(feature: MGLPointFeature) {
    performSegue(withIdentifier: Storyboard.MapToProfileChild, sender: feature.attributes)
  }
  
  public func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    loadUsers(
      latitude: lat,
      longitude: lng,
      radius: radiusInMiles
    ) {
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
    }
  }
  
  public func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  public func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
    mapView.removeAnnotations([annotation])
  }
  
  public func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    // Create an empty view annotation. Set a frame to offset the callout.
    return MGLAnnotationView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
  }

  
//  public func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//    guard let annotation = annotation as? UserPointAnnotation else {
//      return nil
//    }
//    
//    guard let reuseIdentifier = annotation.reuseIdentifier else {
//      return nil
//    }
//    
//    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//
//    if annotationView == nil {
//      annotationView = UserAnnotationView(reuseIdentifier: reuseIdentifier)
//      annotationView!.frame = CGRect(
//        x: 0,
//        y: 0,
//        width: 80,
//        height: 80
//      )
//      
//      var color: UIColor!
//      
//      if reuseIdentifier == User.currentUser?.uid ?? "" {
//        color = UIColor.hexStringToUIColor(hex: "#37d67c")
//        
//        DispatchQueue.main.async { [weak self] in
//          self?.mapView.selectAnnotation(annotation, animated: true)
//        }
//      } else {
//        color = UIColor.hexStringToUIColor(hex: "#f83f39")
//      }
//
//      annotationView!.backgroundColor = color.withAlphaComponent(0.2)
//      
//      let imageView = UIImageViewCircular()
//      imageView.contentMode = .scaleAspectFill
//      imageView.backgroundColor = UIColor.lightGray
//      imageView.layer.masksToBounds = true
//      imageView.frame = CGRect(
//        x: 0,
//        y: 0,
//        width: 40,
//        height: 40
//      )
//      
//      imageView.makeMeBordered(
//        color: color,
//        borderWidth: 2,
//        cornerRadius: 40 / 2
//      )
//      
//      imageView.center = CGPoint(
//        x: annotationView!.bounds.midX,
//        y: annotationView!.bounds.midY
//      )
//      
//      if let url = URL(string: annotation.imageURL ?? "") {
//        imageView.sd_setImage(with: url)
//      }
//      
//      annotationView!.addSubview(imageView)
//    }
//    
//    
//    return annotationView
//  }
//  
//  
//  
//  
//  public func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
//    return UserCalloutView(representedObject: annotation)
//  }
//  
//  
//  public func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//    return true
//  }
//  
//  public func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
//    performSegue(withIdentifier: Storyboard.MapToProfileChild, sender: annotation)
//    mapView.deselectAnnotation(annotation, animated: true)
//  }
//  
//  public func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//    currentZoomLevel = mapView.zoomLevel
//    print(currentZoomLevel)
//  }
}















































