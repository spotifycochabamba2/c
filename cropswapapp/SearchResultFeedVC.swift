//
//  SearchResultFeedVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/29/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD

// Properties
class SearchResultFeedVC: UICollectionViewController {
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
    if text.characters.count > 3 {
      print("searching")
      SVProgressHUD.show()
      
      Produce.searchFor(filter: text, completion: { [weak self] (produces) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        self?.produces = produces
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










































