//
//  TradeDetailVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/20/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import SVProgressHUD
import Ax

class TradeDetailVC: UIViewController {
  
  var dealId: String?
  var anotherUserId: String?
  var dealState: DealState?
  
  var userUpdatedStateDeal: () -> Void = { }
  
  
  @IBOutlet weak var anotherProduceTitleLabel: UILabel! {
    didSet {
      anotherProduceTitleLabel.text = ""
    }
  }
  
  @IBOutlet weak var anotherProduceUnitTitleLabel: UILabel! {
    didSet {
      anotherProduceUnitTitleLabel.text = ""
    }
  }
  
  @IBOutlet weak var myProduceTitleLabel: UILabel! {
    didSet {
      myProduceTitleLabel.text = ""
    }
  }
  
  @IBOutlet weak var myProduceUnitTitleLabel: UILabel! {
    didSet {
      myProduceUnitTitleLabel.text = ""
    }
  }
  
  var anotherProduces = [(Produce, Int)]()
  var myProduces = [(Produce, Int)]()
  
  @IBOutlet weak var myGardenCollectionView: UICollectionView!
  @IBOutlet weak var anotherGardenCollectionView: UICollectionView!
  
  var currentPageOnMyGarden: Int = 0 {
    didSet {

      if currentPageOnMyGarden >= 0 {
        let produce = myProduces[currentPageOnMyGarden]
        showProduceOnMyGardenUI(produce)
      }
      
    }
  }
  
  var currentPageOnAnotherGarden: Int = 0 {
    didSet {

      if currentPageOnAnotherGarden >= 0 {
        let produce = anotherProduces[currentPageOnAnotherGarden]
        showProduceOnAnothersGardenUI(produce)
      }
    }
  }
  
  func showProduceOnAnothersGardenUI(_ produce: (Produce, Int)) {
    let name = produce.0.name
    let quantity = produce.1
    let quantityType = produce.0.quantityType
    let id = produce.0.id
    anotherProduceUnitTitleLabel.alpha = 1
    
    if id == Constants.Ids.moneyId {
      anotherProduceTitleLabel.text = "Money"
      anotherProduceUnitTitleLabel.isHidden = false
      anotherProduceUnitTitleLabel.text = "$\(quantity)"
    } else if id == Constants.Ids.workerId {
      anotherProduceTitleLabel.text = "Pay with work"
      anotherProduceUnitTitleLabel.alpha = 0
    } else {
      anotherProduceTitleLabel.text = name
      anotherProduceUnitTitleLabel.isHidden = false
      anotherProduceUnitTitleLabel.text = "\(quantity) \(quantityType)"
    }
  }
  
  func showProduceOnMyGardenUI(_ produce: (Produce, Int)) {
    let name = produce.0.name
    let quantity = produce.1
    let quantityType = produce.0.quantityType
    let id = produce.0.id
    myProduceUnitTitleLabel.alpha = 1
    
    if id == Constants.Ids.moneyId {
      myProduceTitleLabel.text = "Money"
      myProduceUnitTitleLabel.isHidden = false
      myProduceUnitTitleLabel.text = "$\(quantity)"
    } else if id == Constants.Ids.workerId {
      myProduceTitleLabel.text = "Pay with work"
      myProduceUnitTitleLabel.alpha = 0
    } else {
      myProduceTitleLabel.text = name
      myProduceUnitTitleLabel.isHidden = false
      myProduceUnitTitleLabel.text = "\(quantity) \(quantityType)"
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

  }
  
  func createMoneyProduce() -> Produce {
    let produce = Produce(
      id: Constants.Ids.moneyId,
      name: "",
      ownerId: "",
      ownerUsername: ""
    )
    
    return produce
  }
  
  func createWorkerProduce() -> Produce {
    let produce = Produce(
      id: Constants.Ids.workerId,
      name: "",
      ownerId: "",
      ownerUsername: ""
    )
    
    return produce
  }
  
  func loadData() {
    if let dealId = dealId {
      SVProgressHUD.show()
      
      var myProducesFound = Array<[String: Any]>()
      var anotherProducesFound = Array<[String: Any]>()
      
      Ax.serial(tasks: [
        
        { done in
          if let currentUserId = User.currentUser?.uid {
            User.getProducesByUser(byUserId: currentUserId, completion: { (myProduces) in
              myProducesFound = myProduces.filter {
                let liveState = $0["liveState"] as? String ?? ""
                
                return liveState != ProduceState.archived.rawValue
              }
              
              done(nil)
            })
          } else {
            done(nil)
          }
        },
        
        { [weak self] done in
          if let anotherUserId = self?.anotherUserId {
            User.getProducesByUser(byUserId: anotherUserId, completion: { (anotherProduces) in
              anotherProducesFound = anotherProduces.filter {
                let liveState = $0["liveState"] as? String ?? ""
                
                return liveState != ProduceState.archived.rawValue
              }
              
              done(nil)
            })
          } else {
            done(nil)
          }
        },
        
        { [weak self] done in
          if let dealState = self?.dealState {
            Deal.getDealProduces(byId: dealId, completion: { [weak self] (ownerProduces, anotherProduces, deal) in

              switch dealState {
              case .tradeRequest:
                self?.anotherProduces = ownerProduces
                self?.myProduces = anotherProduces
                
                let anotherPayWithWork = deal.ownerPayWithWork
                let anotherPayWithMoney = deal.ownerPayWithMoney
                
                let ownerPayWithWork = deal.anotherPayWithWork
                let ownerPayWithMoney = deal.anotherPayWithMoney

                
                anotherProducesFound.forEach { anotherProduce in
                  var exists = false
                  
                  for ownerProduce in self?.anotherProduces ?? [] {
                    let myProduceId = anotherProduce["id"] as? String ?? ""
                    if myProduceId == ownerProduce.0.id {
                      exists = true
                      break
                    }
                  }
                  
                  if !exists {
                    if let id = anotherProduce["id"] as? String,
                      let name = anotherProduce["name"] as? String,
                      let firstPictureURL = anotherProduce["firstPictureURL"] as? String,
                      let quantityType = anotherProduce["quantityType"] as? String,
                      let ownerId = anotherProduce["ownerId"] as? String,
                      let quantity = anotherProduce["quantity"] as? Int
                    {
                      let produce = Produce(
                        id: id,
                        name: name,
                        firstPictureURL: firstPictureURL,
                        quantityType: quantityType,
                        ownerId: ownerId,
                        quantity: quantity,
                        liveState: anotherProduce["liveState"] as? String
                      )
                      
                      self?.anotherProduces.append((produce, 0))
                    }
                  }
                }
                
                let anotherMoneyProduce = self?.createMoneyProduce()
                self?.anotherProduces.append((anotherMoneyProduce!, anotherPayWithMoney))
                
                let anotherWorkerProduce = self?.createWorkerProduce()
                self?.anotherProduces.append((anotherWorkerProduce!, anotherPayWithWork ? 1 : 0))
                
                myProducesFound.forEach { myProduce in
                  var exists = false
                  
                  for ownerProduce in anotherProduces {
                    let myProduceId = myProduce["id"] as? String ?? ""
                    if myProduceId == ownerProduce.0.id {
                      exists = true
                    }
                  }
                  
                  if !exists {
                    if let id = myProduce["id"] as? String,
                      let name = myProduce["name"] as? String,
                      let firstPictureURL = myProduce["firstPictureURL"] as? String,
                      let quantityType = myProduce["quantityType"] as? String,
                      let ownerId = myProduce["ownerId"] as? String,
                      let quantity = myProduce["quantity"] as? Int
                    {
                      let produce = Produce(
                        id: id,
                        name: name,
                        firstPictureURL: firstPictureURL,
                        quantityType: quantityType,
                        ownerId: ownerId,
                        quantity: quantity,
                        liveState: myProduce["liveState"] as? String
                      )
                      
                      self?.myProduces.append((produce, 0))
                    }
                  }
                }
                
                let myMoneyProduce = self?.createMoneyProduce()
                self?.myProduces.append((myMoneyProduce!, ownerPayWithMoney))
                
                let myWorkerProduce = self?.createWorkerProduce()
                self?.myProduces.append((myWorkerProduce!, ownerPayWithWork ? 1 : 0))

              case .waitingAnswer:
                fallthrough
              case .tradeCompleted:
                fallthrough
              case .tradeDeleted:
                fallthrough
              case .tradeCancelled:
//                self?.myProduces = myProducesFound
//                self?.anotherProduces = anotherProducesFound
                
                self?.anotherProduces = anotherProduces
                if deal.anotherPayWithWork {
                  let anotherWorkerProduce = self?.createWorkerProduce()
                  self?.anotherProduces.append((anotherWorkerProduce!, 1))
                }
                
                if deal.anotherPayWithMoney > 0 {
                  let anotherMoneyProduce = self?.createMoneyProduce()
                  self?.anotherProduces.append((anotherMoneyProduce!, deal.anotherPayWithMoney))
                }
                
                self?.myProduces = ownerProduces
                if deal.ownerPayWithWork {
                  let myWorkerProduce = self?.createWorkerProduce()
                  self?.myProduces.append((myWorkerProduce!, 1))
                }
                
                if deal.ownerPayWithMoney > 0 {
                  let myMoneyProduce = self?.createMoneyProduce()
                  self?.myProduces.append((myMoneyProduce!, deal.ownerPayWithMoney))
                }
                
              case .tradeInProcess:
                break
              }
              
              done(nil)
              })
          } else {
            done(nil)
          }
        }
        
      ], result: { [weak self] (error) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
          
          self?.currentPageOnMyGarden = 0
          self?.currentPageOnAnotherGarden = 0
          
          self?.myGardenCollectionView.reloadData()
          self?.anotherGardenCollectionView.reloadData()
        }
      })
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
    
    myGardenCollectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: ItemCell.cellId)
    anotherGardenCollectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: ItemCell.cellId)
    
    myGardenCollectionView.delegate = self
    myGardenCollectionView.dataSource = self
    
    anotherGardenCollectionView.delegate = self
    anotherGardenCollectionView.dataSource = self
    
    let gardenLayout = myGardenCollectionView.collectionViewLayout as! UPCarouselFlowLayout
    gardenLayout.itemSize = CGSize(width: 130, height: 130)
    gardenLayout.scrollDirection = .horizontal
    
    let anotherGardenLayout = anotherGardenCollectionView.collectionViewLayout as! UPCarouselFlowLayout
    anotherGardenLayout.itemSize = CGSize(width: 130, height: 130)
    anotherGardenLayout.scrollDirection = .horizontal
    
    view.backgroundColor = .clear    
  }
  
  var produceContainerVC: ProduceContainerVC?
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.TradeDetailToProduce {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProduceContainerVC
      
      vc?.produce = sender as? Produce
      vc?.isReadOnly = true
      
      produceContainerVC = vc

//      NotificationCenter.default.addObserver(
//        self,
//        selector: #selector(dismissModals(notification:)),
//        name: NSNotification.Name(rawValue: "dismissModals"),
//        object: nil
//      )
    }
  }
  
//  func dismissModals(notification: Notification) {
//    print("backstreet \(produceContainerVC)")
//
//    
//    let rare1 = (presentingViewController as? UINavigationController)?.viewControllers.first
//    let rare2 = (presentedViewController as? UINavigationController)?.viewControllers.first
//    
//    print("backstreet rare1 \(rare1)")
//    print("backstreet rara2 \(rare2)")
//    
//    DispatchQueue.main.async { [weak self] in
//      self?.produceContainerVC?.dismiss(animated: true) {
//        let rare2 = (self?.presentedViewController as? UINavigationController)?.viewControllers.first
//        print("backstreet presenting \(self?.presentingViewController)")
//        print("backstreet presented \(self?.presentedViewController)")
//        print("backstreet after rara2 \(rare2)")
//        rare2?.dismiss(animated: true)
//      }
//    }
////    self.dismiss(animated: true)
//    NotificationCenter.default.removeObserver(
//      self,
//      name: NSNotification.Name(rawValue: "dismissModals"),
//      object: nil
//    )
//  }
  
  deinit {
//    NotificationCenter.default.removeObserver(
//      self,
//      name: NSNotification.Name(rawValue: "dismissModals"),
//      object: nil
//    )
  }
}


extension TradeDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let produceSelected: Produce?
    let cell = collectionView.cellForItem(at: indexPath) as! ItemCell
    
    if anotherGardenCollectionView == collectionView {
      produceSelected = anotherProduces[indexPath.row].0
    } else {
      produceSelected = myProduces[indexPath.row].0
    }
    

    if cell.isWorkerCircle,
       dealState?.rawValue ?? "" == DealState.tradeRequest.rawValue
    {
      cell.payWithWork = !cell.payWithWork
      
      if anotherGardenCollectionView == collectionView {
        anotherProduces[indexPath.row].1 = cell.payWithWork ? 1 : 0
      } else {
        myProduces[indexPath.row].1 = cell.payWithWork ? 1 : 0
      }
      
      userUpdatedStateDeal()
      
    }
    
    if let produce = produceSelected,
        produce.id == Constants.Ids.moneyId ||
        produce.id == Constants.Ids.workerId
    {
      return
    }
    
    if produceSelected != nil {
      performSegue(withIdentifier: Storyboard.TradeDetailToProduce, sender: produceSelected)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if anotherGardenCollectionView == collectionView {
      return anotherProduces.count
    } else {
      return myProduces.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.cellId, for: indexPath) as! ItemCell
    var produceTuple: (Produce, Int)?
    
    if collectionView == anotherGardenCollectionView {
      produceTuple = anotherProduces[indexPath.row]
      cell.isAnotherProduce = true
    } else {
      produceTuple = myProduces[indexPath.row]
      cell.isAnotherProduce = false
    }
    
    cell.imageURLString = produceTuple?.0.firstPictureURL
    cell.produceId = produceTuple?.0.id
    cell.tag = indexPath.row
    cell.processQuantity = processQuantity
    cell.isMoneyCircle = (produceTuple?.0.id ?? "") == Constants.Ids.moneyId
    cell.isWorkerCircle = (produceTuple?.0.id ?? "") == Constants.Ids.workerId
    cell.payWithWork = produceTuple?.1 == 1
    
    cell.dealState = dealState
    
    return cell
  }
  
  func processQuantity(produceId: String, index: Int, whoseGarden: AddItemType, quantity: Int) {
    
    switch whoseGarden {
    case .toGardensAnother:

      if currentPageOnAnotherGarden == index {
        let produce = anotherProduces[index].0
        let value = anotherProduces[index].1
        let result = value + quantity
        
        if produce.liveState ?? "" == ProduceState.archived.rawValue {
          let alert = UIAlertController(title: "Info", message: "You can't trade this item anymore since it was removed.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
          return
        }
        
        if result < 0 {
          let alert = UIAlertController(title: "Info", message: "You have reached the minimun quantity for this produce.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
          return
        }
        
        if result <= produce.quantity || produce.id == Constants.Ids.moneyId {
          
          anotherProduces[index].1 = result >= 0 ? result : 0
          DispatchQueue.main.async { [weak self] in
            self?.userUpdatedStateDeal()
            self?.currentPageOnAnotherGarden = index
          }
        } else {
          let alert = UIAlertController(title: "Info", message: "You have reached the maximum quantity for this produce.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
        }
      }
    case .toMyGarden:
      if currentPageOnMyGarden == index {
        let produce = myProduces[index].0
        let value = myProduces[index].1
        let result = value + quantity
        
        if produce.liveState ?? "" == ProduceState.archived.rawValue {
          let alert = UIAlertController(title: "Info", message: "You can't trade this item anymore since it was removed.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
          return
        }
        
        if result < 0 {
          let alert = UIAlertController(title: "Info", message: "You have reached the minimun quantity for this produce.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
          return
        }
        
        if result <= produce.quantity || produce.id == Constants.Ids.moneyId {
          myProduces[index].1 = result >= 0 ? result : 0
          DispatchQueue.main.async { [weak self] in
            self?.userUpdatedStateDeal()
            self?.currentPageOnMyGarden = index
          }
        } else {
          let alert = UIAlertController(title: "Info", message: "You have reached the maximum quantity for this produce.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 130, height: 130)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let layout: UPCarouselFlowLayout!
    
    if myGardenCollectionView === scrollView {
      layout = myGardenCollectionView.collectionViewLayout as! UPCarouselFlowLayout
    } else {
      layout = anotherGardenCollectionView.collectionViewLayout as! UPCarouselFlowLayout
    }
    
    var pageSize = layout.itemSize
    pageSize.width += layout.minimumLineSpacing
    
    let pageSide = pageSize.width
    let offset = scrollView.contentOffset.x
    let value = Int(floor((offset - pageSide / 2) / pageSide) + 1)

    if myGardenCollectionView === scrollView {
      currentPageOnMyGarden = value
    } else {
      currentPageOnAnotherGarden = value
    }
  }
}


































