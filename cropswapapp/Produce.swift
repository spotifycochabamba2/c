//
//  Produce.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import Ax

enum ProducePhotoNumber: String {
  case first = "firstPictureURL"
  case second = "secondPictureURL"
  case third = "thirdPictureURL"
  case fourth = "fourthPictureURL"
  case fifth = "fifthPictureURL"
}

enum ProduceStartType: String {
  case plant
  case seed
}

enum ProduceMethods: String {
  case compostTea
  case organic
}

struct Produce {
  var id: String
  
  var name: String
  var description: String
  
  var produceType: String
  var quantityType: String
  var quantity: Int
  var price: Double
  
  var isCompostTea: Bool?
  var isOrganic: Bool?
  
  var isSeedStart: Bool?
  var isPlantStart: Bool?
  
  var ownerId: String
  var ownerUsername: String
  
  var firstPictureURL: String?
  var secondPictureURL: String?
  var thirdPictureURL: String?
  var fourthPictureURL: String?
  var fifthPictureURL: String?
  
  var state = "Seed"
  
  var tags = [(name: String, priority: Int, key: String)]()
  
  init(
    id: String,
    name: String,
    firstPictureURL: String,
    quantityType: String,
    ownerId: String,
    quantity: Int
  ) {
    self.id = id
    self.name = name
    self.description = ""
    self.produceType = ""
    self.quantityType = quantityType
    self.quantity = quantity
    self.firstPictureURL = firstPictureURL
    
    self.price = 0
    
    self.ownerId = ownerId
    self.ownerUsername = ""
  }
  
  init?(json: [String: Any]?) {
    print(json?["id"])
    guard
      let json = json,
      let id = json["id"] as? String,
      let name = json["name"] as? String,
      let description = json["description"] as? String,
      let produceType = json["produceType"] as? String,
      let quantityType = json["quantityType"] as? String,
      let quantity = json["quantity"] as? Int,
      let price = json["price"] as? Double,
      let ownerId = json["ownerId"] as? String,
      let ownerUsername = json["ownerUsername"] as? String
    else {
      return nil
    }
    
    self.id = id
    
    self.name = name
    self.description = description
    self.produceType = produceType
    self.quantityType = quantityType
    self.quantity = quantity
    self.price = price
    
    self.firstPictureURL =  json["firstPictureURL"] as? String
    self.secondPictureURL = json["secondPictureURL"] as? String
    self.thirdPictureURL = json["thirdPictureURL"] as? String
    self.fourthPictureURL = json["fourthPictureURL"] as? String
    self.fifthPictureURL = json["fifthPictureURL"] as? String
    
    self.state = json["state"] as? String ?? "Seed"
    
    self.ownerId = ownerId
    self.ownerUsername = ownerUsername
    
    if let jsonTags = json["tags"] as? [Any] {
      for (_, v) in jsonTags.enumerated() {
        let value = v as? [String: Any]
        
        if let value = value {
          let name = value["name"] as? String ?? ""
          let priority = value["priority"] as? Int ?? 0
          let key = value["id"] as? String ?? ""
          
          self.tags.append((name: name, priority: priority, key: key))
        }
      }
      
    }
    
    if let jsonTags = json["tags"] as? [String: Any] {
      for (key, _) in jsonTags {
        let jsonTag = jsonTags[key] as? [String: Any]
        
        if let jsonTag = jsonTag {
          let name = jsonTag["name"] as? String ?? ""
          let priority = jsonTag["priority"] as? Int ?? 0
          let key = jsonTag["id"] as? String ?? ""
          
          self.tags.append((name: name, priority: priority, key: key))
        }
      }
    }
    
  }
}




extension Produce {
  
  static var refDatabase = FIRDatabase.database().reference()
  static var refStorage = FIRStorage.storage().reference()
  
  static var refDetails = refDatabase.child("details-tags")
  
  static func deleteProduce(
    id: String,
    firstPicURL: String?,
    secondPicURL: String?,
    thirdPicURL: String?,
    fourthPicURL: String?,
    fifthPicURL: String?,
    ownerId: String,
    completion: @escaping (NSError?) -> Void)
  {
    
    let refDatabaseProduces = refDatabase.child("produces")
    let refDatabaseProduce = refDatabaseProduces.child(id)
    
    let refDatabaseProducesByUser = refDatabase.child("produces-by-user")
    let refDatabaseProduceUser = refDatabaseProducesByUser.child(ownerId)
    let refDatabaseProduceByUser = refDatabaseProduceUser.child(id)

    Ax.parallel(tasks: [
      { done in
        refDatabaseProduce.removeValue(completionBlock: { (error, ref) in
          done(error as? NSError)
        })
      },
      
      { done in
        refDatabaseProduceByUser.removeValue(completionBlock: { (error, ref) in
          done(error as? NSError)
        })
      },
      
      { done in
        
        if let firstPicURL = firstPicURL {
          let imageRef = FIRStorage.storage().reference(forURL: firstPicURL)
          imageRef.delete {
            done($0 as? NSError)
          }
        } else {
          done(nil)
        }
      },
      
      { done in
        if let secondPicURL = secondPicURL {
          let imageRef = FIRStorage.storage().reference(forURL: secondPicURL)
          imageRef.delete {
            done($0 as? NSError)
          }
        } else {
          done(nil)
        }
      },
      
      { done in
        if let thirdPicURL = thirdPicURL {
          let imageRef = FIRStorage.storage().reference(forURL: thirdPicURL)
          imageRef.delete {
            done($0 as? NSError)
          }
        } else {
          done(nil)
        }
      },
      
      { done in
        if let fourthPicURL = fourthPicURL {
          let imageRef = FIRStorage.storage().reference(forURL: fourthPicURL)
          imageRef.delete {
            done($0 as? NSError)
          }
        } else {
          done(nil)
        }
      },
      
      { done in
        if let fifthPicURL = fifthPicURL {
          let imageRef = FIRStorage.storage().reference(forURL: fifthPicURL)
          imageRef.delete {
            done($0 as? NSError)
          }
        } else {
          done(nil)
        }
      }
      
    ]) { (error) in
      completion(error)
    }
  }
  
  static func updateProducePicturesOnDatabase(
    byProduceId produceId: String,
    ownerId: String,
    firstPictureURL: String?,
    secondPictureURL: String?,
    thirdPictureURL: String?,
    fourthPictureURL: String?,
    fifthPictureURL: String?
  ) {
    let refDatabaseProduces = refDatabase.child("produces")
    let refDatabaseProduce = refDatabaseProduces.child(produceId)
    
    let refDatabaseProducesByUser = refDatabase.child("produces-by-user")
    let refDatabaseProduceUser = refDatabaseProducesByUser.child(ownerId)
    let refDatabaseProduceByUser = refDatabaseProduceUser.child(produceId)
    
    var values = [String: Any]()
    
    if let firstPictureURL = firstPictureURL {
      values[ProducePhotoNumber.first.rawValue] = firstPictureURL
    }
    
    if let secondPictureURL = secondPictureURL {
      values[ProducePhotoNumber.second.rawValue] = secondPictureURL
    }
    
    if let thirdPictureURL = thirdPictureURL {
      values[ProducePhotoNumber.third.rawValue] = thirdPictureURL
    }
    
    if let fourthPictureURL = fourthPictureURL {
      values[ProducePhotoNumber.fourth.rawValue] = fourthPictureURL
    }
    
    if let fifthPictureURL = fifthPictureURL {
      values[ProducePhotoNumber.fifth.rawValue] = fifthPictureURL
    }
    
    if values.count > 0 {
      refDatabaseProduce.updateChildValues(values)
    }
    
    var valuesForProduceByUser = [String: Any]()
    
    if let firstPictureURL = firstPictureURL {
      valuesForProduceByUser[ProducePhotoNumber.first.rawValue] = firstPictureURL
    }
    
    if valuesForProduceByUser.count > 0 {
      refDatabaseProduceByUser.updateChildValues(valuesForProduceByUser)
    }
  }
  
  static func updateProducePicture(
    byProduceId produceId: String,
    ownerId: String,
    photoNumber: ProducePhotoNumber,
    pictureURL: String,
    completion: @escaping (NSError?) -> Void
  ) {
    let refDatabaseProduces = refDatabase.child("produces")
    let refDatabaseProduce = refDatabaseProduces.child(produceId)
    
    let refDatabaseProducesByUser = refDatabase.child("produces-by-user")
    let refDatabaseProduceUser = refDatabaseProducesByUser.child(ownerId)
    let refDatabaseProduceByUser = refDatabaseProduceUser.child(produceId)
    
    var values = [String: Any]()
    values[photoNumber.rawValue] = pictureURL
    
    Ax.parallel(tasks: [
      
      { done in
        refDatabaseProduce.updateChildValues(values, withCompletionBlock: { (error: Error?, fir: FIRDatabaseReference) in
          done(error as? NSError)
        })
      },
      { done in
        
        if case ProducePhotoNumber.first = photoNumber {
          refDatabaseProduceByUser.updateChildValues(values, withCompletionBlock: { (error: Error?, fir: FIRDatabaseReference) in
            done(error as? NSError)
          })
          
        } else {
          done(nil)
        }
      }
      
      
    ]) { (error) in
      completion(error)
    }
  }
  
  static func updateProduce(
    
    produceId: String,
    name: String,
    description: String,
    
    produceType: String,
    quantityType: String,
    quantity: Int,
    
    price: Double,
    
//    isCompostTea: Bool,
//    isOrganic: Bool,
//    isSeedStart: Bool,
//    isPlantStart: Bool,
    
    ownerId: String,
    
    firstPicURL: String?,
    secondPicURL: String?,
    thirdPicURL: String?,
    fourthPicURL: String?,
    fifthPicURL: String?,
    
    tags: [(String, Bool, Int, String)],
    
    state: String,
    
    completion: @escaping (Result<String>) -> Void
    
  ) {
//    let produceId = id
    
    let refDatabaseProduces = refDatabase.child("produces")
    let refDatabaseProduce = refDatabaseProduces.child(produceId)
    
    let refDatabaseProducesByUser = refDatabase.child("produces-by-user")
    let refDatabaseProduceUser = refDatabaseProducesByUser.child(ownerId)
    let refDatabaseProduceByUser = refDatabaseProduceUser.child(produceId)
    
    var valuesForProduce = [String: Any]()
    
    valuesForProduce["name"] = name
    valuesForProduce["description"] = description
    valuesForProduce["produceType"] = produceType
    valuesForProduce["quantityType"] = quantityType
    valuesForProduce["quantity"] = quantity
    valuesForProduce["price"] = price
    valuesForProduce["state"] = state
    
    print(tags)
    
    if tags.count > 0 {
      var val = [String: Any]()
      
      var child = [String: Any]()
      
      tags.forEach {
        child["id"] = $0.3
        child["name"] = $0.0
        child["priority"] = $0.2
        val[$0.3] = child
      }
      
      print(val)
      valuesForProduce["tags"] = val
    }
    
//    valuesForProduce["isCompostTea"] = isCompostTea
//    valuesForProduce["isOrganic"] = isOrganic
//    valuesForProduce["isSeedStart"] = isSeedStart
//    valuesForProduce["isPlantStart"] = isPlantStart
    
    if let firstPicURL = firstPicURL {
      valuesForProduce[ProducePhotoNumber.first.rawValue] = firstPicURL
    }
    
    if let secondPicURL = secondPicURL {
      valuesForProduce[ProducePhotoNumber.second.rawValue] = secondPicURL
    }
    
    if let thirdPicURL = thirdPicURL {
      valuesForProduce[ProducePhotoNumber.third.rawValue] = thirdPicURL
    }
    
    if let fourthPicURL = fourthPicURL {
      valuesForProduce[ProducePhotoNumber.fourth.rawValue] = fourthPicURL
    }
    
    if let fifthPicURL = fifthPicURL {
      valuesForProduce[ProducePhotoNumber.fifth.rawValue] = fifthPicURL
    }    
    
    var valuesForProduceByUser = [String: Any]()
    valuesForProduceByUser[ProducePhotoNumber.first.rawValue] = firstPicURL
    valuesForProduceByUser["produceType"] = produceType
    valuesForProduceByUser["quantityType"] = quantityType
    valuesForProduceByUser["quantity"] = quantity
    
    Ax.serial(tasks: [
      { done in
        refDatabaseProduce.updateChildValues(valuesForProduce, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
          done(error as? NSError)
        })
      },
      
      { done in
        refDatabaseProduceByUser.updateChildValues(valuesForProduceByUser, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
          done(error as? NSError)
        })
      }
    ]) { (error) in
      if let error = error {
        completion(Result.fail(error: error))
      } else {
        completion(Result.success(data: produceId))
      }
    }
  }
  
  static func generateProduceId() -> String {
    let refDatabaseProduces = refDatabase.child("produces")
    return refDatabaseProduces.childByAutoId().key
  }
  
  static func saveProduce(
    produceId: String,
    name: String,
    description: String,
    
    produceType: String,
    quantityType: String,
    quantity: Int,
    
    price: Double,
//    isCompostTea: Bool,
//    isOrganic: Bool,
//    
//    isSeedStart: Bool,
//    isPlantStart: Bool,
    
    ownerId: String,
    ownerUsername: String,
    
    firstPicURL: String,
    secondPicURL: String,
    thirdPicURL: String,
    fourthPicURL: String,
    fifthPicURL: String,
    
    tags: [(String, Bool, Int, String)],
    
    state: String,
    
    completion: @escaping (Result<String>) -> Void
  ) {
    let refDatabaseProduces = refDatabase.child("produces")
    let refDatabaseProduce = refDatabaseProduces.child(produceId)
    
//    let produceId = produceId
    
    let refDatabaseProducesByUser = refDatabase.child("produces-by-user")
    let refDatabaseProduceUser = refDatabaseProducesByUser.child(ownerId)
    let refDatabaseProduceByUser = refDatabaseProduceUser.child(produceId)
    
    var valuesForProduce = [String: Any]()
    valuesForProduce["id"] = produceId
    valuesForProduce["ownerId"] = ownerId
    valuesForProduce["ownerUsername"] = ownerUsername
    
    valuesForProduce["name"] = name
    valuesForProduce["description"] = description
    valuesForProduce["produceType"] = produceType
    valuesForProduce["quantityType"] = quantityType
    valuesForProduce["quantity"] = quantity
    valuesForProduce["price"] = price
    valuesForProduce["state"] = state
    
    if tags.count > 0 {
      var val = [String: Any]()
      
      var child = [String: Any]()
      
      tags.forEach {
        child["id"] = $0.3
        child["name"] = $0.0
        child["priority"] = $0.2
        val[$0.3] = child
      }
      
      print(val)
      valuesForProduce["tags"] = val
    }
//    valuesForProduce["isCompostTea"] = isCompostTea
//    valuesForProduce["isOrganic"] = isOrganic
//    valuesForProduce["isSeedStart"] = isSeedStart
//    valuesForProduce["isPlantStart"] = isPlantStart
    
    valuesForProduce[ProducePhotoNumber.first.rawValue] = firstPicURL
    valuesForProduce[ProducePhotoNumber.second.rawValue] = secondPicURL
    valuesForProduce[ProducePhotoNumber.third.rawValue] = thirdPicURL
    valuesForProduce[ProducePhotoNumber.fourth.rawValue] = fourthPicURL
    valuesForProduce[ProducePhotoNumber.fifth.rawValue] = fifthPicURL
    
    let currentDateUTC = NSDate().timeIntervalSince1970
    
    // used for purposes of sorting in desc order
    //http://stackoverflow.com/questions/36589452/in-firebase-how-can-i-query-the-most-recent-10-child-nodes
    valuesForProduce["timestamp"] = 0 - (currentDateUTC * 1000)
    
    var valuesForProduceByUser = [String: Any]()
    valuesForProduceByUser["name"] = name
    valuesForProduceByUser[ProducePhotoNumber.first.rawValue] = firstPicURL
    valuesForProduceByUser["produceType"] = produceType
    valuesForProduceByUser["quantityType"] = quantityType
    valuesForProduceByUser["quantity"] = quantity
    valuesForProduceByUser["timestamp"] = 0 - (currentDateUTC * 1000)
    valuesForProduceByUser["price"] = price
    
    Ax.serial(tasks: [
      { done in
        refDatabaseProduce.setValue(valuesForProduce, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
          done(error as? NSError)
        })
      },
      
      { done in
        refDatabaseProduceByUser.setValue(valuesForProduceByUser, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
          done(error as? NSError)
        })
      }
    ]) { (error) in
      if let error = error {
        completion(Result.fail(error: error))
      } else {
        completion(Result.success(data: produceId))
      }
    }
  }
  
  static func saveProducePicture(
    pictureData: Data,
    ownerId: String,
    produceId: String,
    photoNumber: ProducePhotoNumber,
//    isMain: Bool = false,
    completion: @escaping (Result<String>) -> Void
  ) {
    
    let refStorageProduces = refStorage.child("produces")
    let refStorageProduce = refStorageProduces.child(produceId)
    let refStorageProduceImageNumber = refStorageProduce.child(photoNumber.rawValue)
    let refStorageProduceImage = refStorageProduceImageNumber.child("\(produceId).jpg")
    
//    let refDatabaseProduces = refDatabase.child("produces")
//    let refDatabaseProduce = refDatabaseProduces.child(produceId)
//    
//    let refDatabaseProducesByUser = refDatabase.child("produces-by-user")
//    let refDatabaseProduceUser = refDatabaseProducesByUser.child(ownerId)
//    let refDatabaseProduceByUser = refDatabaseProduceUser.child(produceId)
    
    var pictureURL: String?
    
    Ax.serial(tasks: [
      
      { done in
        _ = refStorageProduceImage.put(
          pictureData,
          metadata: nil,
          completion: { (metadata: FIRStorageMetadata?, error: Error?) in
            pictureURL = metadata?.downloadURL()?.absoluteString
            done(error as? NSError)
        })
        
      },
//      { done in
//        if let pictureURL = pictureURL {
//          var values = [String: Any]()
//          values[photoNumber.rawValue] = pictureURL
//          
//          refDatabaseProduce.updateChildValues(values)
//          
//          if isMain {
//            refDatabaseProduceByUser.updateChildValues(values)
//          }
//          
//          done(nil)
//        } else {
//          let error = NSError(domain: "AddProduce", code: 0, userInfo: [
//            NSLocalizedDescriptionKey: "No picture URL was generated."
//            ])
//          
//          done(error)
//        }
//
//      }
      
      ], result: { error in
        if let error = error {
          completion(Result.fail(error: error))
        } else {
          completion(Result.success(data: pictureURL!))
        }
    })
  }
  
  static func getProduce(
    byProduceId produceId: String,
    completion: @escaping (Produce?) -> Void
  ) {
    let refDatabaseProduces = refDatabase.child("produces")
    let refDatabaseProduce = refDatabaseProduces.child(produceId)
    
    refDatabaseProduce.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if let json = snap.value as? [String: Any] {
          let produce = Produce(json: json)
          completion(produce)
        } else {
          completion(nil)
        }
      } else {
        completion(nil)
      }
    }
  }
  
  static func getDetails(completion: @escaping ([[String: Any]]) -> Void) {
    refDetails.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      var details = [[String: Any]]()
      
      if snap.exists() {
        if let strings = snap.children.allObjects as? [FIRDataSnapshot] {
          details = strings.flatMap {
            var val = $0.value as? [String: Any]
            val?["key"] = $0.key
            return val
          }
        }
      }
      
      completion(details)
    }
  }
  
  
  static func getProduceTypes(completion: ([(name: String, quantityType: String)]) -> Void) {
    var produceTypes = [(name: String, quantityType: String)]()
    
    produceTypes.append((name: "Abiu", quantityType: "unit"))
    produceTypes.append((name: "Acai", quantityType: "cup"))
    produceTypes.append((name: "Agave", quantityType: "leaf"))
    
    produceTypes.append((name: "Apricot", quantityType: "unit"))
    produceTypes.append((name: "Apple", quantityType: "unit"))
    produceTypes.append((name: "Almond", quantityType: "cup"))
    produceTypes.append((name: "Amaranth", quantityType: "unit"))
    produceTypes.append((name: "Artichoke", quantityType: "unit"))
    produceTypes.append((name: "Arugula", quantityType: "bunch"))
    produceTypes.append((name: "Asparagus", quantityType: "stem"))
    produceTypes.append((name: "Avocado", quantityType: "unit"))
    produceTypes.append((name: "Bananas", quantityType: "unit"))
    
    produceTypes.append((name: "Basil", quantityType: "handful"))
    produceTypes.append((name: "Bay Leaf", quantityType: "unit"))
    produceTypes.append((name: "Beans (bush)", quantityType: "handful"))
    produceTypes.append((name: "Bananas (pole)", quantityType: "handful"))
    produceTypes.append((name: "Beet", quantityType: "unit"))
    produceTypes.append((name: "Blackberry", quantityType: "cup"))
    produceTypes.append((name: "Blueberry", quantityType: "cup"))
    produceTypes.append((name: "Bok Choy", quantityType: "cup"))
    produceTypes.append((name: "Borage", quantityType: "unit"))
    produceTypes.append((name: "Broccoli", quantityType: "bunch"))
    
    produceTypes.append((name: "Brussels Sprouts", quantityType: "unit"))
    produceTypes.append((name: "Cabbage", quantityType: "head"))
    produceTypes.append((name: "Cantaloupe", quantityType: "unit"))
    produceTypes.append((name: "Carrot", quantityType: "unit"))
    produceTypes.append((name: "Catnip", quantityType: "handful"))
    produceTypes.append((name: "Cauliflower", quantityType: "unit"))
    produceTypes.append((name: "Celeriac", quantityType: "knot"))
    produceTypes.append((name: "Celery", quantityType: "stalk"))
    produceTypes.append((name: "Chamomile", quantityType: "handful"))
    produceTypes.append((name: "Cherimoya", quantityType: "unit"))
    
    produceTypes.append((name: "Cherry", quantityType: "cup"))
    produceTypes.append((name: "Chestnut", quantityType: "cup"))
    produceTypes.append((name: "Chili Pepper", quantityType: "unit"))
    produceTypes.append((name: "Chinese Cabbage", quantityType: "head"))
    produceTypes.append((name: "Chives", quantityType: "bunch"))
    produceTypes.append((name: "Cilantro", quantityType: "bunch"))
    produceTypes.append((name: "Collards", quantityType: "unit"))
    produceTypes.append((name: "Comfrey", quantityType: "unit"))
    produceTypes.append((name: "Corn", quantityType: "ear"))
    produceTypes.append((name: "Cranberry", quantityType: "cup"))
    
    produceTypes.append((name: "Cucumber", quantityType: "unit"))
    produceTypes.append((name: "Currants", quantityType: "cup"))
    produceTypes.append((name: "Dates", quantityType: "cup"))
    produceTypes.append((name: "Dill", quantityType: "handful"))
    produceTypes.append((name: "Echinacea", quantityType: "unit"))
    produceTypes.append((name: "Edamame", quantityType: "cup"))
    produceTypes.append((name: "Eggplant", quantityType: "unit"))
    produceTypes.append((name: "Elderberries", quantityType: "cup"))
    produceTypes.append((name: "Endive", quantityType: "bunch"))
    produceTypes.append((name: "Fennel", quantityType: "unit"))
    
    produceTypes.append((name: "Fig", quantityType: "unit"))
    produceTypes.append((name: "Garlic", quantityType: "bulb"))
    produceTypes.append((name: "Ginger", quantityType: "finger"))
    produceTypes.append((name: "Gooseberry", quantityType: "cup"))
    produceTypes.append((name: "Gourds", quantityType: "unit"))
    produceTypes.append((name: "Grape", quantityType: "cluster"))
    produceTypes.append((name: "Grapefruit", quantityType: "unit"))
    produceTypes.append((name: "Greens", quantityType: "unit"))
    produceTypes.append((name: "Guava", quantityType: "unit"))
    produceTypes.append((name: "Honeydew", quantityType: "unit"))
    
    produceTypes.append((name: "Horseradish", quantityType: "finger"))
    produceTypes.append((name: "Huckleberry", quantityType: "cup"))
    produceTypes.append((name: "Jackfruit", quantityType: "unit"))
    produceTypes.append((name: "Jeruselem Artichoke", quantityType: "unit"))
    produceTypes.append((name: "Jicama", quantityType: "tuber"))
    produceTypes.append((name: "Jostaberry", quantityType: "cup"))
    produceTypes.append((name: "Kale", quantityType: "bunch"))
    produceTypes.append((name: "Kiwi", quantityType: "unit"))
    produceTypes.append((name: "Kohlrabi", quantityType: "stem"))
    produceTypes.append((name: "Lavender", quantityType: "bunch"))
    
    produceTypes.append((name: "Leek", quantityType: "bunch"))
    produceTypes.append((name: "Lemon", quantityType: "unit"))
    produceTypes.append((name: "LemonBalm", quantityType: "handful"))
    produceTypes.append((name: "Lemon Verbena", quantityType: "handful"))
    produceTypes.append((name: "Lettuce", quantityType: "bunch"))
    produceTypes.append((name: "Lime", quantityType: "unit"))
    produceTypes.append((name: "Loganberry", quantityType: "cup"))
    produceTypes.append((name: "Lovage", quantityType: "bunch"))
    produceTypes.append((name: "Mache", quantityType: "bunch"))
    produceTypes.append((name: "Majoram", quantityType: "handful"))
    
    produceTypes.append((name: "Malanga", quantityType: "unit"))
    produceTypes.append((name: "Mango", quantityType: "unit"))
    produceTypes.append((name: "Medlar", quantityType: "unit"))
    produceTypes.append((name: "Melon", quantityType: "unit"))
    produceTypes.append((name: "Mint", quantityType: "handful"))
    produceTypes.append((name: "Mulberry", quantityType: "cup"))
    produceTypes.append((name: "Mushrooms", quantityType: "cup"))
    produceTypes.append((name: "Musketmelon", quantityType: "unit"))
    produceTypes.append((name: "Mustard greens", quantityType: "bunch"))
    produceTypes.append((name: "Nectarines", quantityType: "unit"))
    
    produceTypes.append((name: "Oats", quantityType: "cup"))
    produceTypes.append((name: "Okra", quantityType: "handful"))
    produceTypes.append((name: "Olives", quantityType: "cup"))
    produceTypes.append((name: "Onion", quantityType: "unit"))
    produceTypes.append((name: "Orange", quantityType: "unit"))
    produceTypes.append((name: "Oregano", quantityType: "handful"))
    produceTypes.append((name: "Papaya", quantityType: "unit"))
    produceTypes.append((name: "Parsley", quantityType: "bunch"))
    produceTypes.append((name: "Parsnip", quantityType: "unit"))
    produceTypes.append((name: "Passion Fruit", quantityType: "unit"))
    
    produceTypes.append((name: "Peach", quantityType: "unit"))
    produceTypes.append((name: "Peanut", quantityType: "cup"))
    produceTypes.append((name: "Pear", quantityType: "unit"))
    produceTypes.append((name: "Peas", quantityType: "handful"))
    produceTypes.append((name: "Pecan", quantityType: "cup"))
    produceTypes.append((name: "Pepper", quantityType: "unit"))
    produceTypes.append((name: "Persimmon", quantityType: "unit"))
    produceTypes.append((name: "Pineapple", quantityType: "unit"))
    produceTypes.append((name: "Plum", quantityType: "unit"))
    produceTypes.append((name: "Pomegranate", quantityType: "unit"))
    
    produceTypes.append((name: "Prickly Pear", quantityType: "unit"))
    produceTypes.append((name: "Pumpkin", quantityType: "unit"))
    produceTypes.append((name: "Radicchio", quantityType: "head"))
    produceTypes.append((name: "Radish", quantityType: "unit"))
    produceTypes.append((name: "Raspberry", quantityType: "cup"))
    produceTypes.append((name: "Rhubarb", quantityType: "bunch"))
    produceTypes.append((name: "Roselle", quantityType: "cup"))
    produceTypes.append((name: "Rosemary", quantityType: "handful"))
    produceTypes.append((name: "Rutabaga", quantityType: "unit"))
    produceTypes.append((name: "Rye", quantityType: "unit"))
    
    produceTypes.append((name: "Sage", quantityType: "leaf"))
    produceTypes.append((name: "Salsify", quantityType: "unit"))
    produceTypes.append((name: "Sapote", quantityType: "unit"))
    produceTypes.append((name: "Scallions", quantityType: "bunch"))
    produceTypes.append((name: "Shallots", quantityType: "cup"))
    produceTypes.append((name: "Sorghum", quantityType: "unit"))
    produceTypes.append((name: "Sorrel", quantityType: "bunch"))
    produceTypes.append((name: "Soybeans", quantityType: "cup"))
    produceTypes.append((name: "Spinach", quantityType: "bunch"))
    produceTypes.append((name: "Squash (winter)", quantityType: "unit"))
    
    produceTypes.append((name: "Squash (summer)", quantityType: "unit"))
    produceTypes.append((name: "Starfruit", quantityType: "unit"))
    produceTypes.append((name: "Stevia", quantityType: "bunch"))
    produceTypes.append((name: "Strawberry", quantityType: "unit"))
    produceTypes.append((name: "Sweet Potato", quantityType: "unit"))
    produceTypes.append((name: "Swiss Chard", quantityType: "bunch"))
    produceTypes.append((name: "Tamarind", quantityType: "cup"))
    produceTypes.append((name: "Tangerine", quantityType: "unit"))
    produceTypes.append((name: "Tarragon", quantityType: "handful"))
    produceTypes.append((name: "Tatsoi", quantityType: "bunch"))
    
    produceTypes.append((name: "Thyme", quantityType: "handful"))
    produceTypes.append((name: "Tomatillo", quantityType: "unit"))
    produceTypes.append((name: "Tomato", quantityType: "unit"))
    produceTypes.append((name: "Turnip", quantityType: "unit"))
    produceTypes.append((name: "Valerian", quantityType: "unit"))
    produceTypes.append((name: "Vanilla", quantityType: "bean"))
    produceTypes.append((name: "Walnut", quantityType: "unit"))
    produceTypes.append((name: "Watercress", quantityType: "bunch"))
    produceTypes.append((name: "Watermelon", quantityType: "unit"))
    produceTypes.append((name: "Wheat", quantityType: "unit"))
    
    produceTypes.append((name: "Yam", quantityType: "unit"))
    produceTypes.append((name: "Zucchini", quantityType: "unit"))
    
    completion(produceTypes)
  }
  
}


















