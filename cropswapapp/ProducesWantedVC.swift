//
//  ProducesWanted.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/15/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class ProducesWantedVC: UICollectionViewController {
  
  var cellId = "ProduceWantedCell"
  var produceTypes = [(produceType: ProduceWanted, isSelected: Bool)]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    SVProgressHUD.show()
    Ax.serial(tasks: [
      
      { done in
        ProduceWanted.getProduceTypes { [weak self] (produceTypes) in
          self?.produceTypes = produceTypes.map {
            return (produceType: $0, selected: false)
          }
          
          DispatchQueue.main.async { [weak self] in
            if let this = self {
              UIView.transition(
                with: this.collectionView!,
                duration: 0.35,
                options: .transitionCrossDissolve,
                animations: {
                  this.collectionView!.reloadData()
                },
                completion: nil
              )
            }
            
            done(nil)
          }
        }
      },
      
      { [unowned self] done in
        
        guard let userId = User.currentUser?.uid else {
          done(nil)
          return
        }
        
        // to do in cloud functinos
        // get already the produces selected
        ProduceWanted.getProducesWanted(ByUserId: userId, completion: { (producesWanted) in
          let indexes: [Int] = producesWanted.flatMap {
            let produceWanted = $0
            return self.produceTypes.index(where: { (produceType) -> Bool in
              return produceType.produceType.id == produceWanted.id
            })
          }
          
          let indexPaths: [IndexPath] = indexes.map {
            self.produceTypes[$0].isSelected = true
            return IndexPath(item: $0, section: 0)
          }
          
          self.collectionView?.performBatchUpdates({
            self.collectionView?.reloadItems(at: indexPaths)
            done(nil)
            }, completion: nil)
          
        })
      }
      
    ]) { (error) in
      SVProgressHUD.dismiss()
    }
    
    view.backgroundColor = UIColor(patternImage: UIImage(named: "mygarden-background")!)
    
    setupCollectionView()
    setNavBarButtons()
  }
  
  
  func setupCollectionView() {
    collectionView?.backgroundColor = .clear
    collectionView?.backgroundView = UIView(frame: CGRect.zero)
  }
  
  func setNavBarButtons() {
    let leftButtonIcon = setNavIcon(imageName: "back-icon", size: CGSize(width: 24, height: 25), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(leftButtonIconTouched), for: .touchUpInside)
  }
  
  func leftButtonIconTouched() {
    _ = navigationController?.popViewController(animated: true)
  }
}


extension ProducesWantedVC: UICollectionViewDelegateFlowLayout {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return produceTypes.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var produceType = produceTypes[indexPath.row]

    produceType.isSelected = !produceType.isSelected

    produceTypes[indexPath.row] = produceType
    guard let userId = User.currentUser?.uid else { return }
    
    if produceType.isSelected {
      SVProgressHUD.show()
      ProduceWanted.addProduceWanted(
        toUserId: userId,
        produceWantedId: produceType.produceType.id,
        completion: { [weak self] (error) in
          SVProgressHUD.dismiss()
          if let error = error {

          } else {
            self?.collectionView?.reloadItems(at: [indexPath])
          }
        }
      )
    } else {
      SVProgressHUD.show()
      ProduceWanted.removeProduceWanted(
        toUserId: userId,
        produceWantedId: produceType.produceType.id,
        completion: { [weak self] (error) in
          SVProgressHUD.dismiss()
          if let error = error {

          } else {
            self?.collectionView?.reloadItems(at: [indexPath])
          }
        }
      )
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProduceWantedCell
    
    let produceType = produceTypes[indexPath.row]

    cell.name = produceType.produceType.name

    cell.isProduceSelected = produceType.isSelected
    cell.configure()

    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.size.width/3.01, height: collectionView.frame.size.width/3);
  }
  
}














































