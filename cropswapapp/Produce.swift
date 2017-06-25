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

enum ProduceState: String {
  case archived = "archived"
}

enum ProducePhotoNumber: String {
  case first = "firstPictureURL"
  case second = "secondPictureURL"
  case third = "thirdPictureURL"
  case fourth = "fourthPictureURL"
  case fifth = "fifthPictureURL"
}

enum ProduceStartType: String {
  case seed = "seed"
  case plant = "plant"
  case harvest = "harvest"
  case other = "other"
}

enum ProduceMethods: String {
  case compostTea
  case organic
}

public struct Produce {
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
  
  var liveState: String?
  
  var tags = [(name: String, priority: Int, key: String)]()
  var tags2 = [String]()
  var tags3 = [String: Any]()
  
  init(
    id: String,
    name: String,
    ownerId: String,
    ownerUsername: String
  )
  {
    self.id = id
    self.name = name
    self.ownerId = ownerId
    self.ownerUsername = ownerUsername
    self.description = ""
    self.produceType = ""
    self.quantityType = ""
    self.quantity = 0
    self.price = 0
  }
  
  init(
    id: String,
    name: String,
    firstPictureURL: String,
    quantityType: String,
    ownerId: String,
    quantity: Int,
    liveState: String?
  ) {
    self.id = id
    self.name = name
    self.description = ""
    self.produceType = ""
    self.quantityType = quantityType
    self.quantity = quantity
    self.firstPictureURL = firstPictureURL
    self.liveState = liveState
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
    
    self.liveState = json["liveState"] as? String
    
    self.ownerId = ownerId
    self.ownerUsername = ownerUsername
    
//    if let jsonTags = json["tags"] as? [[String: Any]] {
//      jsonTags.forEach { group in
//        if let group = group as? [[String: Any]] {
//          group.forEach { tag in
//            if let name = tag["name"] as? String {
//              tags2.append(name)
//            }
//          }
//        }
//      }
//    }
    
//    if let jsonTags = json["tags2"] as? [Any] {
//      for (_, v) in jsonTags.enumerated() {
//        let value = v as? [String: Any]
//        print(value)
//      }
//    }
    
    if let jsonTags = json["tags"] as? [String: Any] {
      print(jsonTags)
      tags3 = jsonTags
//      for (key, _) in jsonTags {
//        if let jsonTag = jsonTags[key] as? [Any] {
//          for (innerKey, v) in jsonTag.enumerated() {
//            if let value = v as? [String: Any] {
//              print(value)
//              tags3[key][innerKey] = value
//            }
//          }
//          
//        }
//      }
    }
    
//    if let jsonTags = json["tags"] as? [Any] {
//      for (_, v) in jsonTags.enumerated() {
//        let value = v as? [String: Any]
//        
//        if let value = value {
//          let name = value["name"] as? String ?? ""
//          let priority = value["priority"] as? Int ?? 0
//          let key = value["id"] as? String ?? ""
//          
//          self.tags.append((name: name, priority: priority, key: key))
//        }
//      }
//      
//    }
//    
//    if let jsonTags = json["tags"] as? [String: Any] {
//      for (key, _) in jsonTags {
//        let jsonTag = jsonTags[key] as? [String: Any]
//        
//        if let jsonTag = jsonTag {
//          let name = jsonTag["name"] as? String ?? ""
//          let priority = jsonTag["priority"] as? Int ?? 0
//          let key = jsonTag["id"] as? String ?? ""
//          
//          self.tags.append((name: name, priority: priority, key: key))
//        }
//      }
//    }
    
  }
}




extension Produce {
  
  static var refDatabase = CSFirebase.refDatabase
  static var refStorage = FIRStorage.storage().reference()
  
  static var refDetails = refDatabase.child("details-tags")
  static var refProduceTypes = refDatabase.child("produce-types")
  
  static var refTags = refDatabase.child("tags")
  
  static func getTagNamesFrom(tags: [String: Any]) -> [String] {
    var tagNames = [String]()
    
    for (_, groupValue) in tags {
      if let dictionaries = groupValue as? [String: Any] {
        for (_, tagValue) in dictionaries {
          if let tagValue = tagValue as? [String: Any],
            let name = tagValue["name"] as? String
          {
            tagNames.append(name)
          }
        }
      }
    }
    
    return tagNames
  }
  
  static func getTags(
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    refTags.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      var tags = [[String: Any]]()
      
      if snap.exists() {
        if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          tags = dictionaries.flatMap {
            print($0.key)
            print($0.value)
            
            var value = [String: Any]()
            value[$0.key] = $0.value
            
            print(value)
            
            return value
          }
        }
      }
      
      completion(tags)
    }
  }
  
  static func searchFor(
    filter: String,
    completion: @escaping ([Produce]) -> Void
  ) {
    let producesFound = [Produce]()
    
    if (User.currentUser?.uid) != nil {
      Algolia.searchFor(filter: filter, completion: { (produces) in
        completion(produces)
      })
    } else {
      completion(producesFound)
    }
  }
  
  static func archiveProduce(
    produceId: String,
    ownerUserId: String,
    completion: @escaping (NSError?) -> Void
  ) {
    let refDatabaseProduces = refDatabase.child("produces")
    let refDatabaseProduce = refDatabaseProduces.child(produceId)
    
    let refDatabaseUserProduce = refDatabase
      .child("produces-by-user")
      .child(ownerUserId)
      .child(produceId)
    
    var values = [String: Any]()
    values["liveState"] = ProduceState.archived.rawValue
    values["quantity"] = 0
    
    refDatabaseUserProduce.updateChildValues(values) { (error: Error?, ref: FIRDatabaseReference) in
    }
    
    refDatabaseProduce.updateChildValues(values) { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as NSError?)
    }
  }
  
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
    
    tags: [String: Any],
    
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
    
//    if tags.count > 0 {
//      var val = [String: Any]()
//      
//      var child = [String: Any]()
//      
//      tags.forEach {
//        child["id"] = $0.3
//        child["name"] = $0.0
//        child["priority"] = $0.2
//        val[$0.3] = child
//      }
//      
//      print(val)
//      valuesForProduce["tags"] = val
      
//    }
    
    valuesForProduce["tags"] = tags
    
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
    
    tags: [String: Any],
    
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
    
//    if tags.count > 0 {
//      var val = [String: Any]()
//      
//      var child = [String: Any]()
//      
//      tags.forEach {
//        child["id"] = $0.3
//        child["name"] = $0.0
//        child["priority"] = $0.2
//        val[$0.3] = child
//      }
      
//      print(val)
//      valuesForProduce["tags"] = tags
//    }
    valuesForProduce["tags"] = tags
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
  
  
  static func getProduceTypes(
    completion: @escaping ([(name: String, quantityType: String)]
  ) -> Void) {
    
    refProduceTypes.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      var produceTypes = [(name: String, quantityType: String)]()
      
      if snap.exists() {
        if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          produceTypes = dictionaries.flatMap {
            let val = $0.value as? [String: Any]
            print(val)
            if let name = val?["name"] as? String {
              return (name: name, quantityType: "")
            } else {
              return nil
            }
          }
        }
      }
      
      completion(produceTypes)
    }
  }
  
}


















