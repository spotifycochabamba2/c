//
//  AddItemTradeVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import Ax
import SVProgressHUD

enum AddItemType {
  case toMyGarden
  case toGardensAnother
}

class MakeDealVC: UIViewController {
  var currentProduceId: String?
  var anotherOwnerId: String?
  var anotherUsername: String?
  
  
  var transactionMethod: String?
  
//  var pageSize: CGSize {
//    let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
//    var pageSize = layout.itemSize
//    if layout.scrollDirection == .horizontal {
//      pageSize.width += layout.minimumLineSpacing
//    } else {
//      pageSize.height += layout.minimumLineSpacing
//    }
//    return pageSize
//  }
  
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
  
  var anotherProduces = [[String: Any]]()
  var myProduces = [[String: Any]]()
  
  @IBOutlet weak var myGardenCollectionView: UICollectionView!
  @IBOutlet weak var anotherGardenCollectionView: UICollectionView!
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  var numberFormatter = { () -> NumberFormatter in
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .currencyAccounting
    formatter.currencyCode = "USD"
    
    return formatter
  }()
  
  func showProduceOnMyGardenUI(_ produce: [String: Any]) {
    let name = produce["produceType"] as? String ?? ""
    let quantity = produce["quantityAdded"] as? Int ?? 0
    let quantityType = produce["quantityType"] as? String ?? ""
    let id = produce["id"] as? String ?? ""
    myProduceUnitTitleLabel.alpha = 1
    
    if id == Constants.Ids.moneyId {
      myProduceTitleLabel.text = "Money"
//      myProduceUnitTitleLabel.isHidden = false
      myProduceUnitTitleLabel.text = "$\(quantity)"
    } else if id == Constants.Ids.workerId {
      myProduceTitleLabel.text = "Pay with work"
      myProduceUnitTitleLabel.alpha = 0
    } else {
      myProduceTitleLabel.text = name
//      myProduceUnitTitleLabel.isHidden = false
      myProduceUnitTitleLabel.text = "\(quantity) \(quantityType)"
//      myProduceUnitTitleLabel.text = numberFormatter.string(from: NSNumber(value: quantity))
    }
  }
  
  func showProduceOnAnothersGardenUI(_ produce: [String: Any]) {
    let name = produce["produceType"] as? String ?? ""
    let quantity = produce["quantityAdded"] as? Int ?? 0
    let quantityType = produce["quantityType"] as? String ?? ""
//    let pictureURL = produce["firstPictureURL"] as? String
    let id = produce["id"] as? String ?? ""
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
  
  var currentPageOnMyGarden: Int = 0 {
    didSet {
      print(currentPageOnMyGarden)
      if currentPageOnMyGarden >= 0 {
        let produce = myProduces[currentPageOnMyGarden]
        showProduceOnMyGardenUI(produce)
      }
      
    }
  }
  
  var currentPageOnAnotherGarden: Int = 0 {
    didSet {
      print(currentPageOnAnotherGarden)
      if currentPageOnAnotherGarden >= 0 {
        let produce = anotherProduces[currentPageOnAnotherGarden]
        showProduceOnAnothersGardenUI(produce)
      }

    }
  }
  
  @IBAction func cancelButtonTouched() {
    dismiss(animated: true)
  }
  
  @IBOutlet weak var acceptButton: UIButton!
  
  @IBAction func acceptButtonTouched() {
    acceptButton.isEnabled = false
    acceptButton.alpha = 0.5
    
    let anotherProducesSelected = anotherProduces.filter { (produce) -> Bool in  // true include and false exclude
      let quantityAdded = produce["quantityAdded"] as? Int ?? 0
      
      return quantityAdded > 0
    }
    
    let myProducesSelected = myProduces.filter {
      let quantityAdded = $0["quantityAdded"] as? Int ?? 0
      
      return quantityAdded > 0
    }

    
    if anotherProducesSelected.count <= 0  {
      acceptButton.isEnabled = true
      acceptButton.alpha = 1
      
      let alert = UIAlertController(title: "Error", message: "At least add quantity of one produce of another's garden you want to trade", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    if myProducesSelected.count <= 0 {
      acceptButton.isEnabled = true
      acceptButton.alpha = 1
      
      let alert = UIAlertController(title: "Error", message: "At least add quantity of one produce of your garden you want to trade", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    var ownerUserFound: User?
    var anotherUserFound: User?
    
    guard let anotherId = anotherOwnerId else {
      acceptButton.isEnabled = true
      acceptButton.alpha = 1
      
      let alert = UIAlertController(title: "Error", message: "Another person Id invalid.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    guard let ownerId = User.currentUser?.uid else {
      acceptButton.isEnabled = true
      acceptButton.alpha = 1
      
      let alert = UIAlertController(title: "Error", message: "Owner user id invalid.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    SVProgressHUD.show()
    Ax.serial(tasks: [
      { [weak self] done in
        User.getUser(completion: { (result) in
          switch result {
          case .success(let user):
            ownerUserFound = user
            done(nil)
          case .fail(let error):
            done(error)
          }
        })
      },
      
      { [weak self] done in
        User.getUser(byUserId: self?.anotherOwnerId, completion: { (result) in
          switch result {
          case .success(let user):
            anotherUserFound = user
            self?.anotherUsername = user.name
            done(nil)
          case .fail(let error):
            done(error)
          }
        })
      },
      
      { [weak self] done in
                
        guard let anotherUsername = self?.anotherUsername else {
          let error = NSError(domain: "MakeDeal", code: 0, userInfo: [NSLocalizedDescriptionKey: "Another person Username invalid."])
          
          done(error)
          return
        }
        
        guard let ownerUsername = ownerUserFound?.name else {
          let error = NSError(domain: "MakeDeal", code: 0, userInfo: [NSLocalizedDescriptionKey: "Owner person Username invalid."])
          
          done(error)
          return
        }
        
        var deal = Deal(
          ownerUserId: ownerId,
          anotherUserId: anotherId,
          ownerUsername: ownerUsername,
          anotherUsername: anotherUsername,
          ownerProduces: myProducesSelected,
          anotherProduces: anotherProducesSelected
        )
        
        deal.transactionMethod = self?.transactionMethod
        
        Deal.create(deal, completion: { (error) in
          done(error)
        })
      }
      
    ]) { [weak self] (error) in
      DispatchQueue.main.async { [weak self] in
        self?.acceptButton.isEnabled = true
        self?.acceptButton.alpha = 1
        
        SVProgressHUD.dismiss()
      }
      
      if let error = error {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
          self?.present(alert, animated: true)
        }
      } else {
        DispatchQueue.main.async {
          self?.performSegue(withIdentifier: Storyboard.MakeDealToDealSubmitted, sender: anotherUserFound)
        }
      }
    }
  }
  
  func createMoneyProduce() -> [String: Any] {
    var values = [String: Any]()
    values["id"] = Constants.Ids.moneyId
    
    return values
  }
  
  func createWorkerProduce() -> [String: Any] {
    var values = [String: Any]()
    values["id"] = Constants.Ids.workerId
    values["isActive"] = false
    
    return values
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    let produce = Produce(json: [:])
//    myProduces.append(produce!)
    
    SVProgressHUD.show()
    Ax.parallel(tasks: [
      
      { [weak self] done in
        if let myUserId = User.currentUser?.uid {
          User.getProducesByUser(byUserId: myUserId, completion: { (myProduces) in
            self?.myProduces = myProduces.filter {
              let liveState = $0["liveState"] as? String ?? ""
              
              return liveState != ProduceState.archived.rawValue
            }
            
            let moneyProduce = self?.createMoneyProduce()
            self?.myProduces.append(moneyProduce!)
            
            let workerProduce = self?.createWorkerProduce()
            self?.myProduces.append(workerProduce!)

            DispatchQueue.main.async {
              self?.myGardenCollectionView.reloadData()
              if myProduces.count > 0 {
                self?.currentPageOnMyGarden = 0
              }
            }
          
            done(nil)
          })
        } else {
          done(nil)
        }
      },
      
      { [weak self] done in
        if let anotherOwnerId = self?.anotherOwnerId {
          User.getProducesByUser(byUserId: anotherOwnerId, completion: { (anotherProduces) in
            self?.anotherProduces = anotherProduces.filter {
              let liveState = $0["liveState"] as? String ?? ""
              
              return liveState != ProduceState.archived.rawValue
            }
            
            let moneyProduce = self?.createMoneyProduce()
            self?.anotherProduces.append(moneyProduce!)
            
            let workerProduce = self?.createWorkerProduce()
            self?.anotherProduces.append(workerProduce!)
            
            let produceIndex = self?.anotherProduces.index(where: { (produce) -> Bool in
              let produceId = produce["id"] as! String
              print(produceId)
              print(self?.currentProduceId)
              
              return produceId == self?.currentProduceId ?? ""
            })
            
            
            
            print(produceIndex)
            
            DispatchQueue.main.async {
              self?.anotherGardenCollectionView.reloadData()
              self?.currentPageOnAnotherGarden = 0
             
              
              if let produceIndex = produceIndex, produceIndex >= 0 {
                let indexPath = IndexPath(item: Int(produceIndex), section: 0)
                self?.anotherGardenCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self?.currentPageOnAnotherGarden = produceIndex
              } else {
                self?.currentPageOnAnotherGarden = 0
              }
            }
            
            done(nil)
          })
        } else {
          done(nil)
        }
      }
      
    ]) { (error) in
      SVProgressHUD.dismiss()
      
    }
    
    myGardenCollectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: ItemCell.cellId)
    anotherGardenCollectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: ItemCell.cellId)

    myGardenCollectionView.delegate = self
    myGardenCollectionView.dataSource = self
    
    anotherGardenCollectionView.delegate = self
    anotherGardenCollectionView.dataSource = self
    
    
    let gardenLayout = myGardenCollectionView.collectionViewLayout as! UPCarouselFlowLayout
    gardenLayout.itemSize = CGSize(width: 150, height: 150)
    gardenLayout.scrollDirection = .horizontal
    
    let anotherGardenLayout = anotherGardenCollectionView.collectionViewLayout as! UPCarouselFlowLayout
    anotherGardenLayout.itemSize = CGSize(width: 150, height: 150)
    anotherGardenLayout.scrollDirection = .horizontal
    
    
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
  }
  
  func itemDidAdd(_ newProduce: Produce, _ whoseGarden: AddItemType) {
    switch whoseGarden {
      
    case .toGardensAnother:
//      anotherProduces.append(newProduce)
      anotherGardenCollectionView.reloadData()
      
    case .toMyGarden:
//      myProduces.append(newProduce)
      myGardenCollectionView.reloadData()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.MakeDealToAddItemToDeal {
      let data = sender as? [String: Any]
      let ownerId = data?["ownerId"] as? String
      
      let vc = segue.destination as? AddItemToDealVC
      vc?.itemDidAdd = itemDidAdd
      vc?.ownerId = ownerId
      vc?.whoseGarden = data?["whoseGarden"] as? AddItemType
      vc?.ownerUsername = data?["anotherOwnerUsername"] as? String
//      vc?.producesAlreadySelected = anotherProduces
    } else if segue.identifier == Storyboard.MakeDealToDealSubmitted {
      let vc = segue.destination as? DealSubmittedVC
      
      let anotherUser = sender as? User
      
      vc?.anotherUsername = anotherUser?.name
      vc?.anotherPictureURL = anotherUser?.profilePictureURL
      // anotherPictureURL
      // anotherUsername
    } else if segue.identifier == Storyboard.MakeDealToProduce {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProduceContainerVC
      
      let dictionary = sender as? [String: Any]
      let id = dictionary?["id"] as? String ?? ""
      let name = dictionary?["name"] as? String ?? ""
      let ownerId = dictionary?["ownerId"] as? String ?? ""
      let ownerUsername = dictionary?["ownerUsername"] as? String ?? ""
      
      let produce = Produce(
        id: id,
        name: name,
        ownerId: ownerId,
        ownerUsername: ownerUsername
      )
      
      vc?.produce = produce
      vc?.isReadOnly = true
    }
  }
}

extension MakeDealVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let produceSelected: [String: Any]?
    let cell = collectionView.cellForItem(at: indexPath) as! ItemCell
    
    if anotherGardenCollectionView === collectionView {
      produceSelected = anotherProduces[indexPath.row]
      
      if cell.isWorkerCircle {
        cell.payWithWork = !cell.payWithWork
        anotherProduces[indexPath.row]["isActive"] = cell.payWithWork
      }
    } else {
      produceSelected = myProduces[indexPath.row]
      
      if cell.isWorkerCircle {
        cell.payWithWork = !cell.payWithWork
        myProduces[indexPath.row]["isActive"] = cell.payWithWork
      }
    }
    
    if let produceSelected = produceSelected,
       let id = produceSelected["id"],
       let name = produceSelected["name"],
       let ownerId = produceSelected["ownerId"]
    {
      var values = [String: Any]()
      values["id"] = id
      values["name"] = name
      values["ownerId"] = ownerId
      values["ownerUsername"] = ""
      
      performSegue(withIdentifier: Storyboard.MakeDealToProduce, sender: values)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if anotherGardenCollectionView === collectionView {
//      return anotherProduces.count + 1
      return anotherProduces.count
    } else {
//      return myProduces.count + 1
      return myProduces.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.cellId, for: indexPath) as! ItemCell
    
    if anotherGardenCollectionView === collectionView {
      let produce = anotherProduces[indexPath.row]
      
      cell.imageURLString = produce["firstPictureURL"] as? String
      cell.isAnotherProduce = true
      cell.produceId = produce["id"] as? String
      cell.processQuantity = processQuantity
      cell.tag = indexPath.row
      cell.isMoneyCircle = (produce["id"] as? String ?? "") == Constants.Ids.moneyId
      cell.isWorkerCircle = (produce["id"] as? String ?? "") == Constants.Ids.workerId
      cell.payWithWork = produce["isActive"] as? Bool ?? false
      
    } else {
      let produce = myProduces[indexPath.row]
      cell.imageURLString = produce["firstPictureURL"] as? String
      
      cell.isAnotherProduce = false
      cell.produceId = produce["id"] as? String
      cell.processQuantity = processQuantity
      cell.tag = indexPath.row
      cell.isMoneyCircle = (produce["id"] as? String ?? "") == Constants.Ids.moneyId
      cell.isWorkerCircle = (produce["id"] as? String ?? "") == Constants.Ids.workerId
      cell.payWithWork = produce["isActive"] as? Bool ?? false
    }
    
    return cell
  }
  
  func processQuantity(produceId: String, index: Int, whoseGarden: AddItemType, quantity: Int) {
    print(produceId)
    print(index)
    print(whoseGarden)
    print(quantity)
    
    switch whoseGarden {
    case .toGardensAnother:
      print(currentPageOnAnotherGarden)
      print(index)
      if currentPageOnAnotherGarden == index {
        print(anotherProduces[index])
        print(anotherProduces[index]["quantity"] as? Int)
        
        let liveState = anotherProduces[index]["liveState"] as? String ?? ""
        let produceQuantity = anotherProduces[index]["quantity"] as? Int ?? 0
        let value = anotherProduces[index]["quantityAdded"] as? Int ?? 0
        let produceId = anotherProduces[index]["id"] as? String ?? ""
        let result = value + quantity
        
        if liveState == ProduceState.archived.rawValue {
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
        
        if result <= produceQuantity || produceId == Constants.Ids.moneyId {
          anotherProduces[index]["quantityAdded"] = result >= 0 ? result : 0
          currentPageOnAnotherGarden = index
        } else {
          let alert = UIAlertController(title: "Info", message: "You have reached the maximum quantity for this produce.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
        }
      }
    case .toMyGarden:
      print(currentPageOnMyGarden)
      print(index)
      if currentPageOnMyGarden == index {
        
        let produceQuantity = myProduces[index]["quantity"] as? Int ?? 0
        
        let value = myProduces[index]["quantityAdded"] as? Int ?? 0
        let result = value + quantity
        let liveState = myProduces[index]["liveState"] as? String ?? ""
        let produceId = myProduces[index]["id"] as? String ?? ""
        
        if liveState == ProduceState.archived.rawValue {
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
        
        
        if result <= produceQuantity || produceId == Constants.Ids.moneyId {
          myProduces[index]["quantityAdded"] = result >= 0 ? result : 0
          currentPageOnMyGarden = index
        } else {
          let alert = UIAlertController(title: "Info", message: "You have reached the maximum quantity for this produce.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
        }
      }
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 150, height: 150)
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




















