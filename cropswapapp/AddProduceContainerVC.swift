//
//  AddProduceContainerVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 3/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import SVProgressHUD
import Ax

class AddProduceContainerVC: UIViewController {
  var currentProduceId: String?
  var currentProduceState: String?
  
  weak var addProduceChildVC: AddProduceChildVC?
  var currentUser: User?
  @IBOutlet weak var bottomBarView: UIView!
  
  @IBOutlet weak var addItemButton: UIButton! {
    didSet {
      addItemButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddProduceContainerToAddProduceChild" {
      let vc = segue.destination as? AddProduceChildVC
      vc?.currentProduceId = currentProduceId
      vc?.currentProduceState = currentProduceState
      vc?.changeTitleButton = changeTitleButton
      vc?.enableProcessButton = enableProcessButton
      addProduceChildVC = vc
    }
  }
  
  func enableProcessButton() {
    if let currentProduceState = currentProduceState,
      currentProduceState == ProduceState.archived.rawValue {
      
      addItemButton.isEnabled = false
      addItemButton.alpha = 0.5
    } else {

      addItemButton.isEnabled = true
      addItemButton.alpha = 1
    }
  }
  
  func changeTitleButton(_ newTitle: String) {
    addItemButton.setTitle(newTitle, for: .normal)
  }
  
  @IBAction func addItemButtonTouched() {
    addItemButton.isEnabled = false
    addItemButton.alpha = 0.5
    
    guard let addProduceChildVC = addProduceChildVC else {
      addItemButton.isEnabled = true
      addItemButton.alpha = 1
      return
    }
    
    guard
      let ownerId = currentUser?.id,
      let ownerUsername = currentUser?.name
      else {
        addItemButton.isEnabled = true
        addItemButton.alpha = 1
        
        let alert = UIAlertController(title: "Error", message: "No user id or name valid was found.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        return
    }
    
    weak var `self` = self
    
    do {
      try addProduceChildVC.areProduceImagesValid()
      let images = addProduceChildVC.getProduceImages()
      let produceName = try addProduceChildVC.getProduceName()
      let category = try addProduceChildVC.getProduceCategory()
      let stateSelected = try addProduceChildVC.getStateSelected()
      let categoryName = category.name
      let quantityType = try addProduceChildVC.getUnitSelected()
      let quantity = try addProduceChildVC.getQuantity()
      let price = try addProduceChildVC.getPrice()
      let description = try addProduceChildVC.getDescription()
      
      let tags = addProduceChildVC.tagsToSave
      
      
      var firstImageData: Data?
      var secondImageData: Data?
      var thirdImageData: Data?
      var fourthImageData: Data?
      var fifthImageData: Data?
      
      if images.count == 1 {
        firstImageData = UIImageJPEGRepresentation(images[0], 0.2)
      } else if images.count == 2 {
        firstImageData = UIImageJPEGRepresentation(images[0], 0.2)
        secondImageData = UIImageJPEGRepresentation(images[1], 0.2)
      } else if images.count == 3 {
        firstImageData = UIImageJPEGRepresentation(images[0], 0.2)
        secondImageData = UIImageJPEGRepresentation(images[1], 0.2)
        thirdImageData = UIImageJPEGRepresentation(images[2], 0.2)
      } else if images.count == 4 {
        firstImageData = UIImageJPEGRepresentation(images[0], 0.2)
        secondImageData = UIImageJPEGRepresentation(images[1], 0.2)
        thirdImageData = UIImageJPEGRepresentation(images[2], 0.2)
        fourthImageData = UIImageJPEGRepresentation(images[3], 0.2)
      } else if images.count == 5 {
        firstImageData = UIImageJPEGRepresentation(images[0], 0.2)
        secondImageData = UIImageJPEGRepresentation(images[1], 0.2)
        thirdImageData = UIImageJPEGRepresentation(images[2], 0.2)
        fourthImageData = UIImageJPEGRepresentation(images[3], 0.2)
        fifthImageData = UIImageJPEGRepresentation(images[4], 0.2)
      }
      
      var firstPicURL: String?
      var secondPicURL: String?
      var thirdPicURL: String?
      var fourthPicURL: String?
      var fifthPicURL: String?
      
      SVProgressHUD.show()
      
      let produceId: String!
      
      if let currentProduceId = currentProduceId {
        produceId = currentProduceId
      } else {
        produceId = Produce.generateProduceId()
      }
      
      Ax.serial(tasks: [
        { done in
          
          Ax.parallel(tasks: [
            
            { innerDone in
              if let firstImageData = firstImageData {
                Produce.saveProducePicture(
                  pictureData: firstImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .first,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      firstPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
            },
            
            { innerDone in
              if let secondImageData = secondImageData {
                Produce.saveProducePicture(
                  pictureData: secondImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .second,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      secondPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
            },
            
            { innerDone in
              if let thirdImageData = thirdImageData {
                Produce.saveProducePicture(
                  pictureData: thirdImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .third,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      thirdPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
            },
            
            { innerDone in
              if let fourthImageData = fourthImageData {
                Produce.saveProducePicture(
                  pictureData: fourthImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .fourth,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      fourthPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
            },
            
            { innerDone in
              if let fifthImageData = fifthImageData {
                Produce.saveProducePicture(
                  pictureData: fifthImageData,
                  ownerId: ownerId,
                  produceId: produceId,
                  photoNumber: .fifth,
                  completion: { (result) in
                    switch result {
                    case .success(let url):
                      fifthPicURL = url
                      innerDone(nil)
                    case .fail(let error):
                      innerDone(error)
                    }
                  }
                )
              } else {
                innerDone(nil)
              }
            }
            
          ], result: { (error) in
            done(error)
          })
        
        },

        { done in
          
          
          if self?.currentProduceId == nil {
            Produce.saveProduce(
              produceId: produceId,
              name: produceName,
              description: description,
              produceType: categoryName,
              quantityType: quantityType,
              quantity: quantity,
              price: price,
              
              ownerId: ownerId,
              ownerUsername: ownerUsername,
              
              firstPicURL: firstPicURL ?? "",
              secondPicURL: secondPicURL ?? "",
              thirdPicURL: thirdPicURL ?? "",
              fourthPicURL: fourthPicURL ?? "",
              fifthPicURL: fifthPicURL ?? "",
              
              tags: tags,
              state: stateSelected,
              completion: { (result) in
                switch result {
                case .fail(let error):
                  done(error as? NSError)
                case .success(_):
                  done(nil)
                }
              }
            )
          } else {
            Produce.updateProduce(
              produceId: produceId,
              name: produceName,
              description: description,
              produceType: categoryName,
              quantityType: quantityType,
              quantity: quantity,
              price: price,
              ownerId: ownerId,
              firstPicURL: firstPicURL ?? "",
              secondPicURL: secondPicURL ?? "",
              thirdPicURL: thirdPicURL ?? "",
              fourthPicURL: fourthPicURL ?? "",
              fifthPicURL: fifthPicURL ?? "",
              
              tags: tags,
              state: stateSelected,
              
              completion: { (result) in
                switch result {
                case .fail(let error):
                  done(error as? NSError)
                case .success(_):
                  done(nil)
                }
            })
          }
        },
        
      ], result: { [weak self] (error) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
          
          self?.addItemButton.isEnabled = true
          self?.addItemButton.alpha = 1
        }
        
        if let error = error {
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          DispatchQueue.main.async {
            self?.present(alert, animated: true)
          }
        } else {
          DispatchQueue.main.async {
            self?.dismiss(animated: true)
          }
        }
      })
      
      
    } catch ValidationFormError.error(let errorMessage) {
      SVProgressHUD.dismiss()
      
      addItemButton.isEnabled = true
      addItemButton.alpha = 1
      
      let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      
    } catch {
      SVProgressHUD.dismiss()
      
      addItemButton.isEnabled = true
      addItemButton.alpha = 1
      
      let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    }
    
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addItemButton.isEnabled = false
    addItemButton.alpha = 0.5
    
    SVProgressHUD.show()
    if self.currentUser == nil {
      User.getUser { [weak self] (result) in
        SVProgressHUD.dismiss()
        
        switch result {
        case .success(let userFound):
          self?.currentUser = userFound
          
          if self?.currentProduceId == nil {
            DispatchQueue.main.async {
              self?.addItemButton.isEnabled = true
              self?.addItemButton.alpha = 1
            }
          }
        case .fail(let error):break
        }
      }
    }
    
    if currentProduceId == nil {
      setNavHeaderTitle(title: "Add Item", color: UIColor.black)
      addItemButton.setTitle("ADD", for: .normal)
    } else {
      setNavHeaderTitle(title: "Edit Item", color: UIColor.black)
      addItemButton.setTitle("EDIT", for: .normal)
      
      if let currentProduceState = currentProduceState,
        currentProduceState == ProduceState.archived.rawValue {
        setNavHeaderTitle(title: "Archived Item", color: UIColor.black)
        
      } else {
        let rightButtonIcon = setNavIcon(imageName: "delete-button-icon", size: CGSize(width: 42, height: 52), position: .right)
        rightButtonIcon.addTarget(self, action: #selector(deleteButtonTouched), for: .touchUpInside)
      }
    }
    
//    (width: 10, height: 17)
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 40, height: 47), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    bottomBarView.layer.shadowOffset = CGSize(width: 0, height: 0);
    bottomBarView.layer.shadowRadius = 2;
    bottomBarView.layer.shadowColor = UIColor.black.cgColor
    bottomBarView.layer.shadowOpacity = 0.3;
  }
  
  func deleteButtonTouched() {
    guard let produceId = currentProduceId else {
      return
    }
    
    guard let ownerUserId = User.currentUser?.uid else {
      return
    }
    
    let alert = UIAlertController(title: "Info", message: "Are you sure you want to delete this produce?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
      
      DispatchQueue.main.async {
        SVProgressHUD.show()
      }
      
      Produce.archiveProduce(
        produceId: produceId,
        ownerUserId: ownerUserId,
        completion: { [weak self] (error) in
          DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self?.dismiss(animated: true)
          }
        })
    }))
    
    present(alert, animated: true, completion: nil)
  }
  
  func backButtonTouched() {
    dismiss(animated: true, completion: nil)
  }
  
}












