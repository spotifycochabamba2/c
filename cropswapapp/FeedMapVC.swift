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
    

    
    mapView = MGLMapView(frame: view.bounds)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    mapView.delegate = self
    
    view.addSubview(mapView)
    view.bringSubview(toFront: currentLocationButton)
    
    loadUsers(
      latitude: lat,
      longitude: lng,
      radius: radiusInMiles
    ) {
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
    }
    
//    Ax.serial(tasks: [
//      { [weak self] done in
//        User.getUser(byUserId: User.currentUser?.uid, completion: { (result) in
//          if let this = self {
//            switch result {
//            case .success(let user):
//              if let latitude = user.latitude,
//                let longitude = user.longitude
//              {
//                this.lat = latitude
//                this.lng = longitude
//                let location = CLLocationCoordinate2DMake(latitude, longitude)
//                this.mapView.setCenter(location, zoomLevel: 12.0, animated: false)
//              }
//              
//              if let radius = user.radiusFilterInMiles {
//                if user.enabledRadiusFilter ?? true {
//                  this.radiusInMiles = radius
//                  this.enabledRadiusFilter = true
//                } else {
//                  this.radiusInMiles = 0
//                  this.enabledRadiusFilter = false
//                }
//              }
//            case .fail(let error):
//              print(error)
//            }
//          }
//          
//          done(nil)
//        })
//      },
//      
//      { [weak self] done in
//        if let this = self {
//          this.loadUsers(
//            latitude: this.lat,
//            longitude: this.lng,
//            radius: this.radiusInMiles
//          ) {
//            done(nil)
//          }
//        } else {
//          done(nil)
//        }
//      }
//      
//    ]) { (error) in
//      DispatchQueue.main.async {
//        SVProgressHUD.dismiss()
//      }
//    }
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
                if let latitude = user.latitude,
                  let longitude = user.longitude
                {
                  this.lat = latitude
                  this.lng = longitude
                  let location = CLLocationCoordinate2DMake(latitude, longitude)
                  
                  DispatchQueue.main.async {
                    print(this.currentZoomLevel)
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
                print(error)
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
            var pointAnnotations = [UserPointAnnotation]()
            
            users.forEach {
              let user = $0
              
              let urlString = user["profilePictureURL"] as? String
              let name = user["name"] as? String
              let location = user["_geoloc"] as? [String: Any]
              let id = user["objectID"] as? String
              
              print(user)
              print(user["name"])
              print(user["_geoloc"])
              
              if let lat = location?["lat"] as? Double,
                let lng = location?["lng"] as? Double
              {
                let coordinate = CLLocationCoordinate2DMake(lat, lng)
                
                let point = UserPointAnnotation(
                  coordinate: coordinate,
                  title: name,
                  subtitle: ""
                )
                
                point.userName = name
                point.imageURL = urlString
                point.reuseIdentifier = id
                
                pointAnnotations.append(point)
              }
            }
            
            DispatchQueue.main.async {
              self?.mapView.addAnnotations(pointAnnotations)
            }
            
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
      let userAnnotation = sender as! UserPointAnnotation
      
      vc?.currentUserId = userAnnotation.reuseIdentifier
      vc?.currentUsername = userAnnotation.userName
      vc?.showBackButton = true
    }
//    } else if segue.identifier == Storyboard.Map
  }
}

extension FeedMapVC: MGLMapViewDelegate {
  public func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    guard let annotation = annotation as? UserPointAnnotation else {
      return nil
    }
    
    guard let reuseIdentifier = annotation.reuseIdentifier else {
      return nil
    }
    
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

    if annotationView == nil {
      annotationView = UserAnnotationView(reuseIdentifier: reuseIdentifier)
      annotationView!.frame = CGRect(
        x: 0,
        y: 0,
        width: 80,
        height: 80
      )
      
      var color: UIColor!
      
      if reuseIdentifier == User.currentUser?.uid ?? "" {
        color = UIColor.hexStringToUIColor(hex: "#37d67c")
        
        DispatchQueue.main.async { [weak self] in
          self?.mapView.selectAnnotation(annotation, animated: true)
        }
      } else {
        color = UIColor.hexStringToUIColor(hex: "#f83f39")
      }

      annotationView!.backgroundColor = color.withAlphaComponent(0.2)
      
      let imageView = UIImageViewCircular()
      imageView.contentMode = .scaleAspectFill
      imageView.backgroundColor = UIColor.lightGray
      imageView.layer.masksToBounds = true
      imageView.frame = CGRect(
        x: 0,
        y: 0,
        width: 40,
        height: 40
      )
      
      imageView.makeMeBordered(
        color: color,
        borderWidth: 2,
        cornerRadius: 40 / 2
      )
      
      imageView.center = CGPoint(
        x: annotationView!.bounds.midX,
        y: annotationView!.bounds.midY
      )
      
      if let url = URL(string: annotation.imageURL ?? "") {
        imageView.sd_setImage(with: url)
      }
      
      annotationView!.addSubview(imageView)
    }
    
    
    return annotationView
  }
  
  
  
  
  public func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
    return UserCalloutView(representedObject: annotation)
  }
  
  
  public func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  public func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
    performSegue(withIdentifier: Storyboard.MapToProfileChild, sender: annotation)
    mapView.deselectAnnotation(annotation, animated: true)
  }
  
  public func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
    currentZoomLevel = mapView.zoomLevel
    print(currentZoomLevel)
  }
  
}















































