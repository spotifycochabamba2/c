//
//  ProduceDetail.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/7/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import iCarousel
import Ax
import SVProgressHUD

class ProduceDetailVC: UIViewController {
  
  let cellId = "ProduceDetailCellId"
  
//  var currentProduce: Produce?
  
  var produceId: String?
  var ownerId: String?
  
  var producePictureURLs = [URL?]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.carousel.reloadData()
      }
    }
  }
  
  @IBOutlet weak var carousel: iCarousel! {
    didSet {
      carousel.type = .coverFlow2
    }
  }
  
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.isHidden = true
    }
  }
  
  @IBOutlet weak var blurView: UIView! {
    didSet {
      let blurEffect = UIBlurEffect(style: .dark)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      
      blurEffectView.frame = blurView.bounds
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      blurView.addSubview(blurEffectView)
    }
  }
  
  @IBOutlet weak var upperView: UIView! {
    didSet {
      upperView.layer.borderColor = UIColor.white.cgColor
      upperView.layer.masksToBounds = true
      upperView.layer.borderWidth = 1.0
      upperView.layer.cornerRadius = 12
    }
  }
  
  @IBOutlet weak var produceNameLabel: UILabel!
  @IBOutlet weak var ownerNameLabel: UILabel!
  @IBOutlet weak var produceDescriptionTextView: UITextView!
  
  @IBOutlet weak var producesCollectionView: UICollectionView!
  
  var produces = [[String: Any]]() {
    didSet {
      DispatchQueue.main.async { [unowned self] in
        self.producesCollectionView.reloadData()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

    view.backgroundColor = .clear
    blurView.backgroundColor = .clear
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    loadProduceToUI()
  }
  
  
  @IBAction func closeButtonTouched(_ sender: AnyObject) {
    dismiss(animated: true)
  }
  
  func loadProduceToUI() {
    
    if
      let ownerId = ownerId,
      let produceId = produceId
    {
      
      SVProgressHUD.show()
      Ax.parallel(tasks: [
        { done in
          Produce.getProduce(byProduceId: produceId, completion: { [unowned self] (produce) in
            
            if let produce = produce {
              let firstURL = URL(string: produce.firstPictureURL!)
              let secondURL = URL(string: produce.secondPictureURL!)
              let thirdURL = URL(string: produce.thirdPictureURL!)
              let fourthURL = URL(string: produce.fourthPictureURL!)
              let fifthURL = URL(string: produce.fifthPictureURL!)
              
              self.producePictureURLs = [firstURL, secondURL, thirdURL, fourthURL, fifthURL]
              
              self.produceDescriptionTextView.text = produce.description
              self.produceNameLabel.text = produce.produceType
              self.ownerNameLabel.text = "\(produce.ownerUsername)'s Garden"
            }
            
            done(nil)
          })
        },
        
        { done in
          User.getProducesByUser(byUserId: ownerId, completion: { [unowned self] (dictionaries) in
            self.produces = dictionaries.filter {
              let iteratedProduceId = $0["id"] as? String ?? ""
              return iteratedProduceId != produceId
            }
            
            done(nil)
          })
        }
      ], result: { (error) in
        SVProgressHUD.dismiss()
      })
    }
  }
}




extension ProduceDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let produce = produces[indexPath.row]
    self.produceId = produce["id"] as? String
    
    DispatchQueue.main.async { [unowned self] in
      self.loadProduceToUI()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return produces.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProduceDetailCell
    
    let produce = produces[indexPath.row]
    let picURL = produce["firstPictureURL"] as? String
    
    cell.pictureURL = picURL
    
    return cell
  }
  
}
















extension ProduceDetailVC: iCarouselDelegate, iCarouselDataSource {
 
  func numberOfItems(in carousel: iCarousel) -> Int {
    return producePictureURLs.count
  }
  
  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    var itemView: UIImageView
    
    if let view = view as? UIImageView {
      itemView = view
    } else {
      let frame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
      itemView = UIImageView(frame: frame)
//      itemView.contentMode = .center
      itemView.contentMode = .scaleAspectFill
      itemView.backgroundColor = UIColor.cropswapRed
      itemView.layer.borderColor = UIColor.white.cgColor
      itemView.layer.masksToBounds = true
      itemView.layer.borderWidth = 1.0
      itemView.layer.cornerRadius = 12
    }
    
    if let url = producePictureURLs[index] {
      itemView.sd_setImage(with: url)
    } else {
      itemView.image = nil
    }
    
    return itemView
  }
  
}



















































