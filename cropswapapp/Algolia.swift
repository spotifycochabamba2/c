//
//  Algolia.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/31/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Alamofire

struct Algolia {
  
  static func searchForUsers(
    filter: String,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    var users = [[String: Any]]()
    
    let url = "\(Constants.Server.stringURL)api/users"
    
    var data = [String: Any]()
    data["filter"] = filter
    
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
          print(data)
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
          }
        case .failure(let error):
          print(error)
        }
        
        completion(users)
    }
  }
  
  static func searchFor(
    filter: String,
    completion: @escaping ([Produce]) -> Void
  ) {
    var produces = [Produce]()
    
    let url = "\(Constants.Server.stringURL)api/produces"
    
    var data = [String: Any]()
    data["filter"] = filter
    
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
          print(data)
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
        case .failure(let error):
          print(error)
        }
        
        completion(produces)
    }
  }
}





























