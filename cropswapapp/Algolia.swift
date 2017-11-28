//
//  Algolia.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/31/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Alamofire
import Ax
import FirebaseAuth

struct Algolia {
  
  static func searchForUsers(
    filter: String,
    completion: @escaping (NSError?, [[String: Any]]) -> Void
  ) {
    
    var users = [[String: Any]]()
    let url = "\(Constants.Server.stringURL)api/users"
    var data = [String: Any]()
    var userToken: String?
    
    data["filter"] = filter
    
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
                let result = data as? [String: Any]
                
                if let dictionaries = result?["users"] as? [[String: Any]]
                {
                  users = dictionaries.flatMap {
                    var values = [String: Any]()
                    values["name"] = $0["name"] as? String
                    values["lastName"] = $0["lastName"] as? String
                    values["profilePictureURL"] = $0["profilePictureURL"] as? String
                    values["about"] = $0["about"] as? String
                    values["id"] = $0["objectID"] as? String
                    
                    return values
                  }
                  
                  done(nil)
                } else {
                  let message = result?["message"] ?? ""
                  
                  let error = NSError(
                    domain: "Users",
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
      completion(error, users)
    }
    
  }
  
  static func searchFor(
    filter: String,
    radius: Int,
    latitude: Double,
    longitude: Double,
    completion: @escaping(NSError?, [Produce]) -> Void
  ) {
    var produces = [Produce]()
    let url = "\(Constants.Server.stringURL)api/v2/produces"
    
    var data = [String: Any]()
    data["filter"] = filter
    data["lat"] = latitude
    data["lng"] = longitude
    data["radius"] = radius
    
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
                let result = data as? [String: Any]
                if let dictionaries = result?["produces"] as? [[String: Any]]
                {
                  produces = dictionaries.flatMap {
                    let liveState = $0["liveState"] as? String ?? ""
                    
                    if liveState != ProduceState.archived.rawValue {
                      return Produce(json: $0)
                    }
                    
                    return nil
                  }
                }
                done(nil)
              case .failure(let error):
                done(error as NSError?)
              }
              
              
          }
        } else {
          let error = NSError(
            domain: "Algolia",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      }
      
    ]) { (error) in
      completion(error, produces)
    }
  }
  
  static func searchFor(
    filter: String,
    completion: @escaping (NSError?, [Produce]) -> Void
  ) {
    var produces = [Produce]()
    let url = "\(Constants.Server.stringURL)api/produces"
    var data = [String: Any]()
    data["filter"] = filter
    
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
                let result = data as? [String: Any]
                if let dictionaries = result?["produces"] as? [[String: Any]]
                {
                  produces = dictionaries.flatMap {
                    let liveState = $0["liveState"] as? String ?? ""
                    
                    if liveState != ProduceState.archived.rawValue {
                      return Produce(json: $0)
                    }
                    
                    return nil
                  }
                }
                done(nil)
              case .failure(let error):
                done(error as NSError?)
              }
              
              
          }
        } else {
          let error = NSError(
            domain: "Algolia",
            code: 0,
            userInfo: [
              NSLocalizedDescriptionKey: "User Token was expired, log in again please."
            ]
          )
          
          done(error)
        }
      }
      
    ]) { (error) in
      completion(error, produces)
    }
  }
}





























