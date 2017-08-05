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
  var username: String? = nil
  var phoneNumber: String? = nil
  var website: String? = nil
  
  var location: String? = nil
  
  var profilePictureURL: String? = nil
  var instagramToken: String? = nil
  var instagramId: String? = nil
  var country: String?
  var street: String?
  var city: String?
  var state: String?
  var zipCode: String?
  var showAddress: Bool?
  var about: String?
  
  var latitude: Double?
  var longitude: Double?
    
  var radiusFilterInMiles: Int?
  var enabledRadiusFilter: Bool?
  
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
    
    self.country = json["country"] as? String
    self.street = json["street"] as? String
    self.city = json["city"] as? String
    self.state = json["state"] as? String
    self.zipCode = json["zipCode"] as? String
    self.showAddress = json["showAddress"] as? Bool
    self.about = json["about"] as? String
    self.username = json["username"] as? String
    
    self.radiusFilterInMiles = json["radiusFilterInMiles"] as? Int
    self.enabledRadiusFilter = json["enabledRadiusFilter"] as? Bool
    
    let publicLocation = json["publicGeoLoc"] as? [String: Any]
    let lat = publicLocation?["lat"] as? Double
    let lng = publicLocation?["lng"] as? Double
    
    self.instagramToken = json["instagramToken"] as? String
    self.instagramId = json["instagramId"] as? String
    
    self.latitude = lat
    self.longitude = lng
  }
  
  init(name: String) {
    self.name = name
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
  static func getCoordinates(
    from: String,
    completion: @escaping (_ latitude: Double, _ longitude: Double) -> Void
  ) {
    let url = "\(Constants.Server.stringURL)api/users/geocode"
    var latitude = Constants.Map.unitedStatesLat
    var longitude = Constants.Map.unitedStatesLng
    
    var data = [String: Any]()
    data["query"] = from
    
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
        case .success(let data):
          let dictionaries = data as? [String: Any]
          
          print(dictionaries)
          print(dictionaries?["latitude"])
          print(dictionaries?["longitude"])
          if let lat = dictionaries?["latitude"] as? Double,
             let lng = dictionaries?["longitude"] as? Double
          {
            latitude = lat
            longitude = lng
          }
        case .failure(let error):
          print(error)
        }
        
        completion(latitude, longitude)
    }
    
  }
  
//  var senderId = req.body.senderId;
//  var receiverId = req.body.receiverId;
//  var dealId = req.body.dealId;
  static func sendRequestLocationPushNotification(
    senderId: String,
    receiverId: String,
    dealId: String,
    completion: @escaping (NSError?) -> Void
  ) {
    let url = "\(Constants.Server.stringURL)send-request-location-push"
    
    var data = [String: Any]()
    data["senderId"] = senderId
    data["receiverId"] = receiverId
    data["dealId"] = dealId
    
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
  
  static func getProducesBy(
    latitude: Double,
    longitude: Double,
    radius: Int,
    completion: @escaping ([Produce], [String]) -> Void
  ) {
    let query = "lat=\(latitude)&lng=\(longitude)&radius=\(radius)"
    let url = "\(Constants.Server.stringURL)api/users/location/produces?\(query)"
    var produces = [Produce]()
    var userIds = [String]()
    
    print(query)
    
    Alamofire
      .request(
        url,
        method: .get,
        encoding: JSONEncoding.default
      )
      .validate()
      .responseJSON { (response) in
        switch response.result {
        case .success(let data):
          let dictionaries = data as? [String: Any]
          
          if let producesFound = dictionaries?["produces"] as? [[String: Any]] ,
             let userIdsFound = dictionaries?["userIds"] as? [String] {
            produces = producesFound.flatMap { Produce(json: $0) }
            userIds = userIdsFound
          }
        case .failure(let error):
          print(error)
        }
        
        completion(produces, userIds)
    }
  }
  
  static func getUsersBy(
    latitude: Double,
    longitude: Double,
    radius: Int,
    completion: @escaping ([[String: Any]]) -> Void
    ) {
    
    let query = "lat=\(latitude)&lng=\(longitude)&radius=\(radius)"
    let url = "\(Constants.Server.stringURL)api/users/location?\(query)"
    var users = [[String: Any]]()
    
    print(query)
    
    Alamofire
      .request(
        url,
        method: .get,
        encoding: JSONEncoding.default
      )
      .validate()
      .responseJSON { (response) in
        switch response.result {
        case .success(let data):
          let dictionaries = data as? [String: Any]
          
          if let usersFound = dictionaries?["users"] as? [[String: Any]] {
            users = usersFound
          }
        case .failure(let error):
          print(error)
        }
        
        completion(users)
    }
    
  }
  
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
  
  static func isValidUsername(input: String) -> Result<Bool> {
    let regex = "[^\\s]+"
    let test = NSPredicate(format:"SELF MATCHES %@", regex)
    
    if !test.evaluate(with: input) {
      let error = NSError(domain: "Signup", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username must not contain spaces."])
      
      return Result.fail(error: error)
    } else {
      return Result.success(data: true)
    }
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
  static var refActiveUsernames = refDatabase.child("active-usernames")
  static var refDatabaseProducesByUser = refDatabase.child("produces-by-user")
  
  static var refDatabaseProduces = refDatabase.child("produces")
  
  static var refStorage = FIRStorage.storage().reference()
  static var refStorageUsers = refStorage.child("users")
  
  
  static func updateProduceCounter(
    userId: String,
    valueToAddOrSubtract: Int
  ) {
    let refDatabaseUser = refDatabaseUsers.child(userId)

    refDatabaseUser.runTransactionBlock { (currentData) -> FIRTransactionResult in
      
      
      if var user = currentData.value as? [String: Any] {
        
        var produceCounter = user["produceCounter"] as? Int ?? 0
        produceCounter += valueToAddOrSubtract
        
        user["produceCounter"] = produceCounter
        
        currentData.value = user
      }
      
      return FIRTransactionResult.success(withValue: currentData)
    }
  }
  
  static func searchFor(
    filter: String,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    Algolia.searchForUsers(
      filter: filter
    ) { (users) in
      completion(users)
    }
  }
  
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
            
            let liveState = item?["liveState"] as? String ?? ""
            
            if liveState != ProduceState.archived.rawValue {
              return item
            }
            
            return nil
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
  
  static func saveEnabledFilterRadius(
    byUserId userId: String,
    enabledFilterRadius: Bool,
    completion: @escaping (NSError?) -> Void
  ) {
    let refUser = refDatabaseUsers.child(userId)
    
    var data = [String: Any]()
    data["enabledRadiusFilter"] = enabledFilterRadius
    
    refUser.updateChildValues(data, withCompletionBlock: {(error, ref) in
      completion(error as? NSError)
    })
  }
  
  static func saveRadius(
    byUserId userId: String,
    radiusInMiles radius: Int,
    completion: @escaping (NSError?) -> Void
  ) {
    let refUser = refDatabaseUsers.child(userId)
    
    var data = [String: Any]()
    data["radiusFilterInMiles"] = radius
    
    refUser.updateChildValues(data, withCompletionBlock: {(error, ref) in
      completion(error as? NSError)
    })
  }
  
  static func saveLatLong(
    byUserId userId: String,
    latitude: Double,
    longitude: Double
  ) {
    
    let refUser = refDatabaseUsers.child(userId)
    
    var values = [String: Any]()
    values["lat"] = latitude
    values["lng"] = longitude
    
    var loc = [String: Any]()
    loc["publicGeoLoc"] = values
    
    refUser.updateChildValues(loc)
  }
  
  static func saveLocation(
    byUserId userId: String,
    country: String,
    street: String? = nil,
    city: String? = nil,
    state: String? = nil,
    zipCode: String,
    showAddress: Bool,
    completion: @escaping (NSError?) -> Void
  ) {
    let refUser = refDatabaseUsers.child(userId)
    var query = ""
    
    if country
            .trimmingCharacters(in: CharacterSet.whitespaces)
            .characters.count <= 0
    {
      let error = NSError(domain: "Authentication", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please provide your country."])
      
      completion(error)
      return
    }
    
    if country == Constants.Map.unitedStatesName {
      if zipCode.trimmingCharacters(in: CharacterSet.whitespaces).characters.count <= 0 {
        let error = NSError(domain: "Authentication", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please provide your zipcode."])
        
        completion(error)
        return
      }
    }
    
    query += "\(country) "
    
    if !(city ?? "").isEmpty {
      query += "\(city!) "
    }
    
    if !(state ?? "").isEmpty {
      query += "\(state!) "
    }
    
    if !zipCode.isEmpty {
      query += "\(zipCode) "
    }
    
    User.getCoordinates(from: query, completion: { (latitude, longitude) in
//      User.saveLatLong(
//        byUserId: userId,
//        latitude: latitude,
//        longitude: longitude
//      )
      
      var values = [String: Any]()
      values["lat"] = latitude
      values["lng"] = longitude
      
      var data = [String: Any]()
      
      data["country"] = country
      data["street"] = street ?? ""
      data["city"] = city ?? ""
      data["state"] = state ?? ""
      data["zipCode"] = zipCode
      data["showAddress"] = showAddress
      data["publicGeoLoc"] = values
      
      refUser.updateChildValues(data, withCompletionBlock: {(error, ref) in
        completion(error as? NSError)
      })
    })
  }
  
  static func signup(
    email: String?,
    andPassword password: String?,
    andFirstName firstName: String,
    andLastName lastName: String,
    andUsername username: String,
    completion: @escaping (NSError?) -> Void
  ) {
    var username = username
    
    if firstName.trimmingCharacters(in: CharacterSet.whitespaces).characters.count < 1 {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "First Name value is empty."
        ])
      
      completion(error)
      return
    }
    
    if lastName.trimmingCharacters(in: CharacterSet.whitespaces).characters.count < 1 {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Last Name value is empty."
        ])
      
      completion(error)
      return
    }
    
    username = username.trimmingCharacters(in: CharacterSet.whitespaces)
    
    username = username.lowercased()
    
    if username.characters.count < 1 {
      let error = NSError(domain: "Auth", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Username value is empty."
        ])
      
      completion(error)
      return
    }
    
    if case Result.fail(let error) = isValidUsername(input: username) {
      completion(error)
      return
    }
    
    var userId: String?

    Ax.serial(tasks: [
      { done in
        let refActiveUsername = refActiveUsernames
                                  .queryOrdered(byChild: "username")
                                  .queryEqual(toValue: username)
        
        refActiveUsername.observeSingleEvent(of: .value, with: { (snap) in
          if snap.exists() {
            let error = NSError(domain: "Auth", code: 0, userInfo: [
              NSLocalizedDescriptionKey: "Username provided is already in use, please provide another one."
            ])
            done(error)
          } else {
            done(nil)
          }
        })
      },
      { done in
        if let email = email,
           let password = password
        {
          FIRAuth.auth()?.createUser(
            withEmail: email,
            password: password,
            completion: { (user, error) in
              userId = user?.uid
              done(error as? NSError)
          })
        } else {
          userId = User.currentUser?.uid
          done(nil)
        }
      },
      
      { done in
        guard let userId = userId else {
          let error = NSError(domain: "Auth", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "No user id created."
          ])
          done(error)
          return
        }
        
        let refUser = refDatabaseUsers.child(userId)
        
        var data = [String: Any]()
        
        if let email = email {
          data["id"] = userId
          data["email"] = email
        }

        data["name"] = firstName
        data["lastName"] = lastName
        data["username"] = username

        refUser.updateChildValues(data) { (error: Error?, _) in
          done(error as NSError?)
        }
      },
      { done in
        let refActiveUsername = refActiveUsernames.childByAutoId()
        
        var data = [String: Any]()
        data["username"] = username
        
        refActiveUsername.updateChildValues(
          data,
          withCompletionBlock: { (error, ref) in
            done(error as NSError?)
        })
      }
    ]) { (error) in
      if let error = error {
        completion(error)
      } else {
        completion(nil)
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
            
            var publicGeoLoc = [String: Any]()
            publicGeoLoc["lat"] = Constants.Map.unitedStatesLat
            publicGeoLoc["lng"] = Constants.Map.unitedStatesLng
            
            var data = [String: Any]()
            data["publicGeoLoc"] = publicGeoLoc
            data["id"] = userId
            data["name"] = user.name
            data["instagramId"] = user.instagramId
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
  
  static func update(
    byUserId userId: String,
    withInstagramId instagramId: String,
    andInstagramToken instagramToken: String,
    completion: @escaping (NSError?) -> Void
  ) {
    var data = [String: Any]()
    data["instagramId"] = instagramId
    data["instagramToken"] = instagramToken
    
    refDatabaseUsers
          .child(userId)
          .updateChildValues(data, withCompletionBlock: {(error, ref) in
            completion(error as NSError?)
          })
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
    username: String,
    phoneNumber: String,
    website: String,
    location: String,
    about: String,
    completion: @escaping (NSError?) -> Void
  ) {
  
    let refDatabaseUser = refDatabaseUsers.child(userId)
    
    var data = [String: Any]()
    data["name"] = firstName
    data["lastName"] = lastName
    data["username"] = username
    data["phoneNumber"] = phoneNumber
    data["website"] = website
    data["location"] = location
    data["about"] = about
    
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
  
  static func hasPendingDeal(
    userIdOne: String?,
    userIdTwo: String?,
    completion: @escaping (Result<[String:Any]?>) -> Void
  ) {
    
    guard let userIdOne = userIdOne else {
      let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User Id One invalid."])
      completion(Result.fail(error: error))
      return
    }
    
    guard let userIdTwo = userIdTwo else {
      let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User Id Two invalid."])
      completion(Result.fail(error: error))
      return
    }
    
    let url = "\(Constants.Server.stringURL)api/user/trade/progress"
    
    var data = [String: Any]()
    data["userOneId"] = userIdOne
    data["userTwoId"] = userIdTwo
    
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
        case .success(let data):
          let dictionary = data as? [String: Any]
          
          print(data as? [String: Any])
          print(dictionary?["deal"] as? [String: Any])
          
          if let _ = dictionary?["error"] as? Bool {
            let message = dictionary?["message"]
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
            
            completion(Result.fail(error: error))
          } else {
            completion(Result.success(data: dictionary?["deal"] as? [String: Any]))
          }
          
        case .failure(let error):
          completion(Result.fail(error: error as NSError))
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
            let instagramId = json["user"]["instagramId"].string,
            let profilePictureURL = json["user"]["profilePictureURL"].string,
            let username = json["user"]["username"].string,
            let firebaseToken = json["firebaseToken"].string
            else {
              let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "incomplete data got from Instagram"])
              completion(Result.fail(error: error))
              return
          }
          
          var user = User(
            name: username,
            profilePictureURL: profilePictureURL,
            instagramToken: instagramToken
          )
          
          user.instagramId = instagramId
          
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





























