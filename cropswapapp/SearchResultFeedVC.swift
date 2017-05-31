//
//  SearchResultFeedVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/29/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

// Properties
class SearchResultFeedVC: UICollectionViewController {
  var produces = [Produce]()
  let cellIdentifier = "FeedCellId"  
}

// Life Cycle
extension SearchResultFeedVC {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = .red
    automaticallyAdjustsScrollViewInsets = false
    collectionView?.alwaysBounceVertical = true
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
    
//    performSegue(withIdentifier: Storyboard.FeedToProduce, sender: produce)
  }
}










































