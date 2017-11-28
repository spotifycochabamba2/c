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
  
  var produceCount: Int?
  
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
    
    self.produceCount = json["produceCount"] as? Int
    
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
    completion: @escaping (NSError?, _ latitude: Double, _ longitude: Double) -> Void
  ) {
    let url = "\(Constants.Server.stringURL)api/users/geocode"
    var latitude = Constants.Map.unitedStatesLat
    var longitude = Constants.Map.unitedStatesLng
    
    var data = [String: Any]()
    data["query"] = from
    
    var userToken: String?
    
    Ax.serial(tasks: [
     
      { done in
        if let user = FIRAuth.auth()?.currentUser {
          user.getTokenForcingRefresh(true, completion: { (token, error) in
            userToken = token
            done(error as NSError?)
          })
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      },
      
      { done in
        if let token = userToken {
          let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
          ]
          
          Alamofire
            .request(
              url,
              method: .post,
              parameters: data,
              encoding: JSONEncoding.default,
              headers: headers
            )
            .validate()
            .responseJSON { (response) in
              switch response.result {
              case .success(let data):
                let dictionaries = data as? [String: Any]
                
                if let lat = dictionaries?["latitude"] as? Double,
                   let lng = dictionaries?["longitude"] as? Double
                {
                  latitude = lat
                  longitude = lng
                  
                  done(nil)
                } else {
                  let message = dictionaries?["message"] as? String ?? ""
                  
                  let error = NSError(
                    domain: "User",
                    code: 0,
                    userInfo: [
                      NSLocalizedDescriptionKey: message
                    ]
                  )
                  
                  done(error)
                }
              case .failure(let error):
                done(error as NSError?)
              }
          }
        } else {
          done(nil)
        }
      }
    ]) { (error) in
      completion(error, latitude, longitude)
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
    
    var userToken: String?
    
    Ax.serial(tasks: [
      
      { done in
        if let user = FIRAuth.auth()?.currentUser {
          user.getTokenForcingRefresh(true, completion: { (token, error) in
            userToken = token
            done(error as NSError?)
          })
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      },
      
      { done in
        if let token = userToken {
          let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
          ]
          
          Alamofire
            .request(
              url,
              method: .post,
              parameters: data,
              encoding: JSONEncoding.default,
              headers: headers
            )
            .validate()
            .responseJSON { (response) in
              switch response.result {
              case .success(_):
                done(nil)
              case .failure(let error):
                done(error as NSError?)
              }
          }
        } else {
          let error = NSError(
            domain: "User",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      }
      
    ]) { (error) in
      completion(error)
    }
  }
  
  static func getProducesBy(
    latitude: Double,
    longitude: Double,
    radius: Int,
    completion: @escaping ([Produce], [String], NSError?) -> Void
  ) {
    
    var userToken: String?
    var produces = [Produce]()
    var userIds = [String]()
    
    Ax.serial(tasks: [
      
      { done in
        if let user = FIRAuth.auth()?.currentUser {
          user.getTokenForcingRefresh(true, completion: { (token, error) in
            userToken = token
            done(error as NSError?)
          })
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      },
      
      { done in
        if let token = userToken {
          let query = "lat=\(latitude)&lng=\(longitude)&radius=\(radius)"
          let url = "\(Constants.Server.stringURL)api/users/location/produces?\(query)"
          
          let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
          ]
          
          Alamofire
            .request(
              url,
              method: .get,
              encoding: JSONEncoding.default,
              headers: headers
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
                break
              }
              
              done(nil)
          }
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          done(error)
        }
      }
      
    ]) { (error) in
      completion(produces, userIds, error)
    }

  }
  
  static func getUsersBy(
    latitude: Double,
    longitude: Double,
    radius: Int,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    
    var users = [[String: Any]]()
    var userToken: String?
    
    Ax.serial(tasks: [
      
      { done in
        if let user = FIRAuth.auth()?.currentUser {
          user.getTokenForcingRefresh(true, completion: { (token, error) in
            userToken = token
            done(error as NSError?)
          })
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      },
      
      { done in
        if let token = userToken {
          let query = "lat=\(latitude)&lng=\(longitude)&radius=\(radius)"
          let url = "\(Constants.Server.stringURL)api/users/location?\(query)"
          
          let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
          ]
          
          Alamofire
            .request(
              url,
              method: .get,
              encoding: JSONEncoding.default,
              headers: headers
            )
            .validate()
            .responseJSON { (response) in
              switch response.result {
              case .success(let data):
                let dictionaries = data as? [String: Any]
                
                if let usersFound = dictionaries?["users"] as? [[String: Any]] {
                  users = usersFound
                }
                done(nil)
              case .failure(let error):
                done(error as NSError?)
              }
          }
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      }
      
    ]) { (error) in
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
  
  static func listenChangesOnUsers(
    completion: @escaping(User) -> Void
  ) {
    refDatabaseUsers.observe(.childChanged) { (snap: FIRDataSnapshot) in
      if
         let json = snap.value as? [String: Any],
         let user = User.init(json: json)
      {
        completion(user)
      }
    }
  }

  
  static func updateProduceCounter(
    userId: String,
    valueToAddOrSubtract: Int
  ) {
    let refDatabaseUser = refDatabaseUsers.child(userId)

    refDatabaseUser.runTransactionBlock { (currentData) -> FIRTransactionResult in
      
      
      if var user = currentData.value as? [String: Any] {
        
        var produceCounter = user["produceCount"] as? Int ?? 0
        produceCounter += valueToAddOrSubtract
        
        user["produceCount"] = produceCounter
        
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
    ) { (error, users) in
      completion(users)
    }
  }
  
  static func logout() {
    
    let cookieStorage = HTTPCookieStorage.shared
    
    if let cookies = cookieStorage.cookies {
      for cookie in cookies {

        let domain = cookie.domain
        
        if domain == "www.instagram.com" ||
          domain == "api.instagram.com" {
          cookieStorage.deleteCookie(cookie)
        }
      }
    }
    
    
    do {
      try FIRAuth.auth()?.signOut()
    } catch let signoutError as NSError {

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
    let refDescOrder = refDatabaseProduces
                            .queryOrdered(byChild: "timestamp")
                            .queryLimited(toFirst: limit + 1)
//                            .queryLimited(toLast: limit)
    
    refDescOrder.observeSingleEvent(of: .value, with: { (snap: FIRDataSnapshot) in
      var produces = [Produce]()
      
      snap.children.allObjects.forEach {
        let children = $0 as? FIRDataSnapshot
        let json = children?.value as? [String: Any]
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
    
    User.getCoordinates(from: query, completion: { (error, latitude, longitude) in
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
      
      Ax.serial(tasks: [
        
        { done in
          FIRAuth.auth()?.signIn(withCustomToken: firebaseToken) { (authUser, error) in
            user.id = authUser?.uid
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
    
    var userToken: String?
    var deals: [String: Any]?
    
    Ax.serial(tasks: [
      
      { done in
        if let user = FIRAuth.auth()?.currentUser {
          user.getTokenForcingRefresh(true, completion: { (token, error) in
            userToken = token
            done(error as NSError?)
          })
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      },
      
      { done in
        if let token = userToken {
          let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
          ]
          
          Alamofire
            .request(
              url,
              method: .post,
              parameters: data,
              encoding: JSONEncoding.default,
              headers: headers
            )
            .validate()
            .responseJSON { (response) in
              switch response.result {
              case .success(let data):
                let dictionary = data as? [String: Any]
                
                if let _ = dictionary?["error"] as? Bool {
                  let message = dictionary?["message"]
                  let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])

                  done(error)
                } else {
                  deals = dictionary?["deal"] as? [String: Any]
                  
                  done(nil)
                }
                
              case .failure(let error):
                done(error as NSError?)
              }
          }
        } else {
          let error = NSError(
            domain: "User",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      }
      
    ]) { (error) in
      if let error = error {
        completion(Result.fail(error: error))
      } else {
        completion(Result.success(data: deals))
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
    
    var userToken: String?
    
    Ax.serial(tasks: [
      
      { done in
        if let user = FIRAuth.auth()?.currentUser {
          user.getTokenForcingRefresh(true, completion: { (token, error) in
            userToken = token
            done(error as NSError?)
          })
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      },
      
      { done in
        if let token = userToken {
          let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
          ]
          
          Alamofire
            .request(
              url,
              method: .post,
              parameters: data,
              encoding: JSONEncoding.default,
              headers: headers
            )
            .validate()
            .responseJSON { (response) in
              switch response.result {
              case .success(_):
                completion(nil)
                done(nil)
              case .failure(let error):
                done(error as NSError?)
              }
          }
        } else {
          let error = NSError(
            domain: "Auth",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      }
      
    ]) { (error) in
      completion(error)
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





























