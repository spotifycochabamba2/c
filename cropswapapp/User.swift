//
//  Service.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 2/20/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Ax

enum Result<T> {
  case success(data: T)
  case fail(error: NSError)
}

struct User {
  var id: String? = nil
  var email: String? = nil
  var name: String
  var lastName: String? = nil
  var phoneNumber: String? = nil
  var website: String? = nil
  
  var location: String? = nil
  
  var profilePictureURL: String? = nil
  var instagramToken: String? = nil
  
  var street: String?
  var city: String?
  var state: String?
  var zipCode: String?
  var showAddress: Bool?
  
  init?(json: [String: Any]?) {
    guard
      let json = json,
      let name = json["name"] as? String,
      let id = json["id"] as? String
    else {
      return nil
    }
    
    self.id = id
    self.name = name
    
    self.email = json["email"] as? String
    self.profilePictureURL = json["profilePictureURL"] as? String
    self.lastName = json["lastName"] as? String
    self.phoneNumber = json["phoneNumber"] as? String
    self.website = json["website"] as? String
    
    self.location = json["location"] as? String
    
    self.street = json["street"] as? String
    self.city = json["city"] as? String
    self.state = json["state"] as? String
    self.zipCode = json["zipCode"] as? String
    self.showAddress = json["showAddress"] as? Bool
  }
  
  init(email: String, name: String) {
    self.email = email
    self.name = name
  }
  
  init(name: String, profilePictureURL: String, instagramToken: String) {
    self.name = name
    self.profilePictureURL = profilePictureURL
    self.instagramToken = instagramToken
  }
}

extension User {
  static func isValid(email: String?) -> Result<Bool> {
    
    guard let email = email,
              !email.isEmpty
    else {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Email value is empty."
      ])
      return Result.fail(error: error)
    }
    
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    if !emailTest.evaluate(with: email) {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Email value is not valid."
      ])
      
      return Result.fail(error: error)
    }
    
    return Result.success(data: true)
  }
  
  static func isValid(password: String) -> Result<Bool> {
    
    guard !password.isEmpty
    else {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Password value is empty."
      ])
      
      return Result.fail(error: error)
    }
    
    // at least 6 characters that password to be valid.
    if password.characters.count < 6 {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Password value should have at least 6 characters."
      ])
      
      return Result.fail(error: error)
    }
    
    return Result.success(data: true)
  }
}

extension User {
  
  static var refDatabase = CSFirebase.refDatabase
  static var refDatabaseUsers = refDatabase.child("users")
  
  static var refDatabaseProducesByUser = refDatabase.child("produces-by-user")
  
  static var refDatabaseProduces = refDatabase.child("produces")
  
  static var refStorage = FIRStorage.storage().reference()
  static var refStorageUsers = refStorage.child("users")
  
  
//  static var 
  
  static func logout() {
    
    let cookieStorage = HTTPCookieStorage.shared
    
    if let cookies = cookieStorage.cookies {
      for cookie in cookies {

        let domain = cookie.domain
        print(domain)
        
        if domain == "www.instagram.com" ||
          domain == "api.instagram.com" {
          cookieStorage.deleteCookie(cookie)
        }
      }
    }
    
    do {
      try FIRAuth.auth()?.signOut()
    } catch let signoutError as NSError {
      print(signoutError)
    }
    
  }
  
  static var currentUser: FIRUser? {
    return FIRAuth.auth()?.currentUser
  }
  
  static func stopListeningToGetProducesByListeningAddedNewOnes(handlerId: UInt, fromTime time: Date) {
    let timestamp = 0 - (time.timeIntervalSince1970 * 1000)
    
    let refDescOrder = refDatabaseProduces
                            .queryOrdered(byChild: "timestamp")
                            .queryEnding(atValue: timestamp)
    refDescOrder.removeObserver(withHandle: handlerId)
  }
  
  static func stopListeningToGetProducesByListeningRemovedOnes(handlerId: UInt) {
    refDatabaseProduces.removeObserver(withHandle: handlerId)
  }
  
  static func stopListeningToGetProducesByUserByListeningUpdatedOnes(handlerId: UInt, fromUserId userId: String) {
    refDatabaseProducesByUser.child(userId).removeObserver(withHandle: handlerId)
  }
  
  static func stopListeningToGetProducesByUserByListeningAddedOnes(handlerId: UInt, fromTime time: Date, fromUserId userId: String) {
    let timestamp = 0 - (time.timeIntervalSince1970 * 1000)
    
    let refDescOrder = refDatabaseProducesByUser
                        .child(userId)
                        .queryOrdered(byChild: "timestamp")
                        .queryEnding(atValue: timestamp)
    refDescOrder.removeObserver(withHandle: handlerId)
  }
 
  static func getProducesByUserByListeningAddedOnes(
    fromTime time: Date,
    fromUserId userId: String,
    completion: @escaping([String: Any]) -> Void
  ) -> UInt {
    let timestamp = 0 - (time.timeIntervalSince1970 * 1000)
    
    let query = refDatabaseProducesByUser
                  .child(userId)
                  .queryOrdered(byChild: "timestamp")
                  .queryEnding(atValue: timestamp)
    
    return query.observe(.childAdded) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if var json = snap.value as? [String: Any] {
          json["id"] = snap.key
          completion(json)
        }
      }
    }
  }
  
  static func getProducesByUserByListeningUpdatedOnes(
    byUserId userId: String,
    completion: @escaping([String: Any]) -> Void
  ) -> UInt {
    return refDatabaseProducesByUser.child(userId).observe(.childChanged, with: { (snap) in
      if snap.exists() {
        if var json = snap.value as? [String: Any] {
          json["id"] = snap.key
          completion(json)
        }
      }
    })
  }
  
  static func getProducesByListeningRemovedOnes(completion: @escaping(String) -> Void) -> UInt {
    return refDatabaseProduces.observe(.childRemoved, with: { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if let dictionary = snap.value as? [String: Any] {
          if let produceId = dictionary["id"] as? String {
            completion(produceId)
          }
        }
      }
    })
  }
  
  static func getProducesByListeningUpdatedOnes(completion: @escaping(Produce) -> Void) -> UInt {
    return refDatabaseProduces.observe(.childChanged, with: { (snap) in
      if snap.exists() {
        if let produce = Produce(json: snap.value as? [String: Any]) {
          completion(produce)
        }
      }
    })
  }
  
  static func getProducesByListeningAddedNewOnes(fromTime time: Date, completion: @escaping (Produce) -> Void) -> UInt {
    let timestamp = 0 - (time.timeIntervalSince1970 * 1000)
    
    let query = refDatabaseProduces
                    .queryOrdered(byChild: "timestamp")
                    .queryEnding(atValue: timestamp)
    
    return query.observe(.childAdded) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if let json = snap.value as? [String: Any] {
          if let produce = Produce(json: json) {
            completion(produce)
          }
        }
      }
    }
    
  }
  
  static func getProducesOnce(byLimit: UInt, startingFrom: String, completion: @escaping ([Produce]) -> Void) {
    print(startingFrom)
    let refProduces = refDatabaseProduces
                          .queryOrderedByKey()
                          .queryEnding(atValue: startingFrom)
                          .queryLimited(toLast: byLimit + 1)

    refProduces.observeSingleEvent(of: .value, with: { (snap: FIRDataSnapshot) in
      var produces = [Produce]()
      
      if snap.exists() {

        
        if var dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          
          if !dictionaries.isEmpty {
            dictionaries.removeLast()
          }
          
          produces = dictionaries.flatMap {
            return Produce(json: $0.value as? [String: Any])
          }
        }
        
      }
      
      
      produces.reverse()
      completion(produces)
    })
  }
  
  static func getProducesOnce(byLimit limit: UInt, completion: @escaping([Produce]) -> Void) -> Void {
    print(limit)
    let refDescOrder = refDatabaseProduces
                            .queryOrdered(byChild: "timestamp")
                            .queryLimited(toFirst: limit + 1)
//                            .queryLimited(toLast: limit)
    
    refDescOrder.observeSingleEvent(of: .value, with: { (snap: FIRDataSnapshot) in
      var produces = [Produce]()
      
      print(snap.children.allObjects.count)
      snap.children.allObjects.forEach {
        let children = $0 as? FIRDataSnapshot
        let json = children?.value as? [String: Any]
        print(json?["id"])
      }
      
      if snap.exists() {
        if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          produces = dictionaries.flatMap {
            return Produce(json: $0.value as? [String: Any])
          }
        }
      }
      completion(produces)
    })
  }
  
  static func getProducesByUser(byUserId userId: String, completion: @escaping (Array<[String: Any]>) -> Void) {
    
    let refDatabaseProduces = refDatabaseProducesByUser.child(userId).queryOrdered(byChild: "timestamp")
    
    refDatabaseProduces.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
      
      var produces = Array<[String: Any]>()
      
      if snap.exists() {
        
        if let dictionaries = snap.children.allObjects as? [FIRDataSnapshot] {
          produces = dictionaries.flatMap {
            print($0.value)
            var item = $0.value as? [String: Any]
            
            item?["id"] = $0.key
            item?["ownerId"] = userId
            
            return item
          }
        }

      }
      print(produces)
      completion(produces)
    }
    
  }
  
  static func getUser(byUserId: String? = nil, completion: @escaping (Result<User>) -> Void) {
    
    let userId: String?
    
    if byUserId != nil {
      userId = byUserId
    } else {
      userId = FIRAuth.auth()?.currentUser?.uid
    }
    
    if let userId = userId {
      let refUser = refDatabaseUsers.child(userId)
      
      print(refUser.url)
      
      refUser.observeSingleEvent(of: .value, with: { (snap) in
        if snap.exists() {
          
          if let user = User(json: snap.value as? [String: Any]) {
            completion(Result.success(data: user))
          } else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [
              NSLocalizedDescriptionKey: "JSON data can't be parsed as User."
            ])
            completion(Result.fail(error: error))
          }
          
        } else {
          let error = NSError(domain: "Auth", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "No user found."
            ])
          completion(Result.fail(error: error))
        }
      })
    } else {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "No user id found."
      ])
      completion(Result.fail(error: error))
    }
    
  }
  
  static func sendResetPasswordTo(email: String, completion: @escaping (Error?) -> Void) {
    
    if case Result.fail(let error) = isValid(email: email) {
      completion(error)
      return
    }
    
    FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
      completion(error)
    })
  }
  
  static func saveLocation(
    byUserId userId: String,
    street: String? = nil,
    city: String? = nil,
    state: String? = nil,
    zipCode: String,
    showAddress: Bool,
    completion: @escaping (NSError?) -> Void
  ) {
    let refUser = refDatabaseUsers.child(userId)
    
    if zipCode.trimmingCharacters(in: CharacterSet.whitespaces).characters.count <= 0 {
      let error = NSError(domain: "Authentication", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please provide at least your zipcode."])
      
      completion(error)
      return
    }
    
    var data = [String: Any]()
    data["street"] = street ?? ""
    data["city"] = city ?? ""
    data["state"] = state ?? ""
    data["zipCode"] = zipCode
    data["showAddress"] = showAddress
    
    refUser.updateChildValues(data, withCompletionBlock: {(error, ref) in
      completion(error as? NSError)
    })
  }
  
  static func signup(
    email: String,
    andName name: String,
    andPassword password: String,
    andRepeatedPassword repeatedPassword: String,
    completion: @escaping (Result<User>) -> Void
  ) {
    var firebaseUser: FIRUser?
    
    if name.trimmingCharacters(in: CharacterSet.whitespaces).characters.count < 1 {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Name value is empty."
        ])
      
      completion(Result.fail(error: error))
      return
    }
    
    if case Result.fail(let error) = isValid(email: email) {
      completion(Result.fail(error: error))
      return
    }
    
    if case Result.fail(let error) = isValid(password: password) {
      completion(Result.fail(error: error))
      return
    }
    
    if password != repeatedPassword {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Password and Repeat Password are not equal."
      ])
      
      completion(Result.fail(error: error))
      return
    }
    
    var user = User(email: email, name: name)

    Ax.serial(tasks: [
      { done in
        
        FIRAuth.auth()?.createUser(
          withEmail: email,
          password: password,
          completion: { (user, error) in
            firebaseUser = user
            done(error as? NSError)
        })

      },
      
      { done in
        
        guard let firebaseUser = firebaseUser else {
          let error = NSError(domain: "Auth", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "No firebase user created."
          ])
          done(error)
          return
        }
        
        let refUser = refDatabaseUsers.child(firebaseUser.uid)
        
        var data = [String: Any]()
        data["id"] = refUser.key
        data["name"] = name
        data["email"] = email
        
        user.id = refUser.key
        
        refUser.setValue(data, withCompletionBlock: {(error, ref) in
          done(error as NSError?)
        })

      }
    ]) { (error) in
      if let error = error {
        completion(Result.fail(error: error))
      } else {
        completion(Result.success(data: user))
      }
    }
  }
  
  
  static func login(
    with user: User,
    and password: String? = nil,
    firebaseToken: String? = nil,
    completion: @escaping (Result<[String: Any]>) -> Void) {
    var user = user
    var userExists = false
    
    if let firebaseToken = firebaseToken {
      print(FIRAuth.auth()?.currentUser)
      
      Ax.serial(tasks: [
        
        { done in
          FIRAuth.auth()?.signIn(withCustomToken: firebaseToken) { (authUser, error) in
            print(user)
            user.id = authUser?.uid
            print(error)
            done(error as NSError?)
          }
        },
        
        { done in
          guard let userId = user.id else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User id was not found."])
            done(error)
            return
          }
          
          refDatabaseUsers.child(userId).observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
            userExists = snap.exists()
            done(nil)
          }
        },
        
        { done in
          if !userExists {
            guard let userId = user.id else {
              let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User id was not found."])
              done(error)
              return
            }
            
            var data = [String: Any]()
            data["id"] = userId
            data["name"] = user.name
            data["instagramToken"] = user.instagramToken
            data["profilePictureURL"] = user.profilePictureURL
            
            refDatabaseUsers.child(userId).setValue(data, withCompletionBlock: {(error, ref) in
              done(error as NSError?)
            })
            
          } else {
            done(nil)
          }
        }
        
      ], result: { (error) in
        if let error = error {
          completion(Result.fail(error: error))
        } else {
          var result = [String: Any]()
          result["user"] = user
          result["isNew"] = !userExists
          
          completion(Result.success(data: result))
        }
      })
    }
    
  }
  
  static func login(
      email: String,
      password: String,
      completion: @escaping (Result<User>) -> Void
    )
  {
    if case Result.fail(let error) = isValid(email: email) {
      completion(Result.fail(error: error))
      return
    }
    
    if case Result.fail(let error) = isValid(password: password) {
      completion(Result.fail(error: error))
      return
    }
    
    var user: User?
    var firebaseUser: FIRUser?
    
    Ax.serial(tasks: [
      
      { done in
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
          if let user = user {
            firebaseUser = user
            done(error as NSError?)
          } else {
            if let error = error {
              done(error as NSError?)
            } else {
              let error = NSError(domain: "Auth", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Firebase user was not found."
                ])
              done(error)
            }
          }
        }
      },
      
      { done in
        let refUser = refDatabaseUsers.child(firebaseUser!.uid)
        
        refUser.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
          if snap.exists() {
            let userFound = User(json: snap.value as? [String: Any])
            
            if let userFound = userFound {
              user = userFound
              done(nil)
            } else {
              let error = NSError(domain: "Auth", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "It couldn't be parsed json to user."
              ])
              done(error)
            }
          } else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [
              NSLocalizedDescriptionKey: "Firebase user was not found."
            ])
            done(error)
          }
        }
      }
      
    ]) { (error) in
      if let error = error {
        completion(Result.fail(error: error))
      } else {
        completion(Result.success(data: user!))
      }
    }
  }
  
  static func updateUser(
    userId: String,
    firstName: String,
    lastName: String,
    phoneNumber: String,
    website: String,
    location: String,
    completion: @escaping (NSError?) -> Void
  ) {
  
    let refDatabaseUser = refDatabaseUsers.child(userId)
    
    var data = [String: Any]()
    data["name"] = firstName
    data["lastName"] = lastName
    data["phoneNumber"] = phoneNumber
    data["website"] = website
    data["location"] = location
    
    refDatabaseUser.updateChildValues(data, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as NSError?)
    })
  }
  
  static func updateUser(byId userId: String, deviceToken: String, completion: @escaping (NSError?) -> Void) {
    let refDatabaseUser = refDatabaseUsers.child(userId)
    
    var data = [String: Any]()
    data["deviceToken"] = deviceToken
    
    refDatabaseUser.updateChildValues(data, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      completion(error as NSError?)
    })
  }
  
  static func updateUserPicture(
    pictureData: Data,
    userId: String,
    completion: @escaping (Result<String>) -> Void
  ) {
    
    var refStorageUser = refStorageUsers.child(userId)
    refStorageUser = refStorageUser.child("\(userId).jpg")
    
    let refDatabaseUser = refDatabaseUsers.child(userId)
    
    var pictureURL: String?
    
    Ax.serial(tasks: [
      
      { done in
        
        _ = refStorageUser.put(pictureData, metadata: nil, completion: { (metadata, error) in
          guard let url = metadata?.downloadURL()?.absoluteString else {
            
            let error = NSError(domain: "", code: 0, userInfo: [
              NSLocalizedDescriptionKey: "it wasn't saved the image on the database."
            ])
            
            done(error)
            return
          }
          
          pictureURL = url
          
          done(error as? NSError)
        })
        
      },
      
      { done in
        var values = [String: Any]()
        
        values["profilePictureURL"] = pictureURL!
        
        refDatabaseUser.updateChildValues(values) { error, ref in
          done(error as? NSError)
        }
      }
      
    ]) { (error) in
      
      if let error = error {
        completion(Result.fail(error: error))
      } else {
        completion(Result.success(data: pictureURL!))
      }
    }
    
  }
  
  static func sendDealPushNotification(
    ownerUserId: String,
    anotherUserId: String,
    dealId: String,
    dealState: String,
    completion: @escaping (NSError?) -> Void
  ) {
    
    let url = "\(Constants.Server.stringURL)send-deal-push"
    
    var data = [String: Any]()
    data["ownerUserId"] = ownerUserId
    data["anotherUserId"] = anotherUserId
    data["dealId"] = dealId
    data["dealState"] = dealState
    
    Alamofire
      .request(
        url,
        method: .post,
        parameters: data,
        encoding: JSONEncoding.default
      )
      .validate()
      .responseJSON { (response) in
        switch response.result {
        case .success(_):
          completion(nil)
        case .failure(let error):
          completion(error as NSError?)
        }
      }
    
  }
  

  static func getFirebaseToken(with code: String, completion: @escaping (Result<[String: Any]>) -> Void) {
    let url = Constants.Instagram.getURLToGetFirebaseToken(code: code)
    
    Alamofire
      .request(url)
      .validate()
      .responseJSON { (response) in
        switch response.result {
        case .success(let data):
          print(data)
          let json = JSON(data)
          
          guard
            let instagramToken = json["user"]["instagramToken"].string,
            let profilePictureURL = json["user"]["profilePictureURL"].string,
            let username = json["user"]["username"].string,
            let firebaseToken = json["firebaseToken"].string
            else {
              let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "imcomplete data got from Instagram"])
              completion(Result.fail(error: error))
              return
          }
          
          let user = User(
            name: username,
            profilePictureURL: profilePictureURL,
            instagramToken: instagramToken
          )
          
          var result = [String: Any]()
          result["user"] = user
          result["firebaseToken"] = firebaseToken
          
          completion(Result.success(data: result))
          break
        case .failure(let error):
          completion(Result.fail(error: error as NSError))
          break
        }
    }
  }
}





























