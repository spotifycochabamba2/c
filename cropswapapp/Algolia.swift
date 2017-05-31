//
//  Algolia.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/31/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Alamofire

struct Algolia {
  
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
