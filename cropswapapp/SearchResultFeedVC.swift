//
//  SearchResultFeedVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/29/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

// Properties
class SearchResultFeedVC: UICollectionViewController {
  
  var currentUser: User?
  var radiusFilterInMiles = 0
  var isEnabledFilter = false
  
  var produces = [Produce]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.collectionView?.reloadData()
      }
    }
  }
  
  let cellIdentifier = "FeedCellId"  
}

// Life Cycle
extension SearchResultFeedVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    
    automaticallyAdjustsScrollViewInsets = true
    collectionView?.alwaysBounceVertical = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    

  }
}



// Methods
extension SearchResultFeedVC {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.SearchResultFeedToProduceContainer {
      
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProduceContainerVC
      
      vc?.produce = sender as? Produce
      
    }
  }
}


// Delegate
extension SearchResultFeedVC: UICollectionViewDelegateFlowLayout {
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FeedCell
    
    let produce = produces[indexPath.row]
    
    cell.producePictureURL = produce.firstPictureURL ?? ""
    cell.produceName = produce.name
    cell.price = produce.price
    cell.distance = 0
    
    if produce.distance == nil {
      let ownerId = produce.ownerId
      
      if let currentUser = currentUser,
        let currentUserLatitude = currentUser.latitude,
        let currentUserLongitude = currentUser.longitude
      {
        User.getUser(byUserId: ownerId, completion: { [weak self] (result) in
          switch result {
          case .success(let user):
            if let anotherUserLatitude = user.latitude,
              let anotherUserLongitude = user.longitude
            {
              
              let distance = Utils.getDistanceInKM(
                fromLatitude: currentUserLatitude,
                fromLongitude: currentUserLongitude,
                toLatitude: anotherUserLatitude,
                toLongitude: anotherUserLongitude
              )
              
              self?.produces[indexPath.row].distance = distance
              DispatchQueue.main.async {
                cell.distance = distance
              }
            } else {
              DispatchQueue.main.async {
                self?.produces[indexPath.row].distance = 0
                cell.distance = 0
              }
            }
          case .fail(let error):
            DispatchQueue.main.async {
              self?.produces[indexPath.row].distance = 0
              cell.distance = 0
            }
          }
          })
      } else {
        produces[indexPath.row].distance = 0
        cell.distance = 0
      }
    } else {
      cell.distance = produce.distance!
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return produces.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 13.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(13, 13, 13, 13)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.frame.size.width / 2) - 20, height: (250))
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let produce = produces[indexPath.row]
    
    performSegue(withIdentifier: Storyboard.SearchResultFeedToProduceContainer, sender: produce)
  }
}

// Delegate
extension SearchResultFeedVC: UISearchControllerDelegate, UISearchBarDelegate { //UISearchResultsUpdating
  
  func willPresentSearchController(_ searchController: UISearchController) {
    SVProgressHUD.dismiss()
  }
  
  func willDismissSearchController(_ searchController: UISearchController) {
    SVProgressHUD.dismiss()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    let text = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
    if text.characters.count >= 3 {
      Ax.serial(tasks: [
        
        { done in
          SVProgressHUD.show()
          User.getUser(byUserId: User.currentUser?.uid) {
            [weak self] (result) in
            
            DispatchQueue.main.async {
              SVProgressHUD.dismiss()
            }
            
            switch result {
            case .success(let user):
              self?.currentUser = user
            case .fail(let error):
              break
            }
            
            done(nil)
          }
        },
        
        { [weak self] done in
          guard let this = self else {
            done(nil)
            return
          }
          
          if let user = self?.currentUser {
            let lat = user.latitude ?? 0
            let lng = user.longitude ?? 0
            var radius = this.radiusFilterInMiles

            if !this.isEnabledFilter {
              radius = 0
            }
            
            Produce.searchFor(
              filter: text,
              radius: radius,
              latitude: lat,
              longitude: lng) { error, produces in
                if let _ = error {
                  
                } else {
                  this.produces = produces
                }
                
                done(nil)
            }
          } else {
            done(nil)
          }
        }
        
      ], result: { (error) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
      })
      

    } else {
      let alert = UIAlertController(title: "Info", message: "Please enter at least 3 or more characters", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    produces.removeAll()
  }
//  func updateSearchResults(for searchController: UISearchController) {
//    let text = searchBar.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
//    if text.characters.count > 3 {
//      SVProgressHUD.show()
//      Produce.searchFor(filter: text, completion: { [weak self] (produces) in
//        DispatchQueue.main.async {
//          SVProgressHUD.dismiss()
//        }
//        
//        self?.produces = produces
//        })
//    }
//  }
  
}










































