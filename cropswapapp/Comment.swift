//
//  Comment.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/7/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FirebaseDatabase

struct Comment {
  var id: String
  var text: String
  var date: Date
  var postId: String
  var ownerId: String
  
  var ownerUsername: String?
  var ownerProfilePictureURL: String?
}

extension Comment {
  init?(json: [String: Any]) {
    guard
      let id = json["id"] as? String,
      let text = json["text"] as? String,
      let date = json["dateCreated"] as? Double,
      let postId = json["postId"] as? String,
      let ownerId = json["ownerId"] as? String
    else {
      return nil
    }
    
    self.id = id
    self.text = text
    self.date = Date(timeIntervalSince1970: date * -1)
    self.postId = postId
    self.ownerId = ownerId
    
    self.ownerUsername = json["ownerUsername"] as? String
    self.ownerProfilePictureURL = json["ownerProfilePictureURL"] as? String
  }
  
}

extension Comment {
  
  static let refDatabase = CSFirebase.refDatabase
  static let refDatabaseComments = refDatabase.child("comments-by-post")
  static let refDatabasePosts = refDatabase.child("post-by-user")
  
//  static func listenDeletesOnComments(
//    
//  ) -> UInt {
//    return 0
//  }

  static func deleteComment(
    wallOwnerId: String,
    postId: String,
    commentId: String,
    completion: @escaping (NSError?) -> Void
  ) {
    // 1) decrement counter on posts
    // 2) delete comment from comments
    
    // 1)
    let refDatabasePost = refDatabasePosts
                            .child(wallOwnerId)
                            .child(postId)
    
    // 2)
    let refDatabaseComment = refDatabaseComments
                              .child(postId)
                              .child(commentId)
    
    refDatabaseComment.removeValue { (error, ref) in
      if let error = error {
        completion(error as NSError?)
      } else {
        refDatabasePost.runTransactionBlock({ (currentData) -> FIRTransactionResult in
          if var post = currentData.value as? [String: Any] {
            
            var commentCounter = post["commentCounter"] as? Int ?? 0
            commentCounter -= 1
            post["commentCounter"] = commentCounter
           
            currentData.value = post
          }
          
          return FIRTransactionResult.success(withValue: currentData)
        })
        
        completion(nil)
      }
    }
  }
  
  static func createComment(
    postId: String,
    commenterId: String,
    wallOwnerId: String,
    text: String,
    date: Date,
    completion: @escaping (NSError?) -> Void
  ) {
    
    guard text.trimmingCharacters(in: CharacterSet.whitespaces).characters.count > 0 else
    {
      let error = NSError(domain: "Posting", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Please provide text before commenting."
        ])
      completion(error)
      return
    }
    
    
    let refComment = refDatabaseComments
                          .child(postId)
                          .childByAutoId()
    
    let refPost = refDatabasePosts
                          .child(wallOwnerId)
                          .child(postId)
    
    
    var values = [String: Any]()
    values["id"] = refComment.key
    values["text"] = text
    values["dateCreated"] = date.timeIntervalSince1970 * -1
    values["postId"] = postId
    values["ownerId"] = commenterId
    
    
    refComment.setValue(values, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
      
      refPost.runTransactionBlock { (currentData) -> FIRTransactionResult in
        
        if var post = currentData.value as? [String: Any] {
          
          var commentCounter = post["commentCounter"] as? Int ?? 0
          commentCounter += 1
          post["commentCounter"] = commentCounter
          
          currentData.value = post
        }
        
        return FIRTransactionResult.success(withValue: currentData)
      }
      
      completion(error as NSError?)
    })
  }
  
  static func getComments(
    byPostId postId: String,
    completion: @escaping (Result<[Comment]>) -> Void
  ) {
    
    let url = "\(Constants.Server.stringURL)api/comments"
    
    var data = [String: Any]()
    data["postId"] = postId
    
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
        case .success(let result):
          if let result = result as? [String: Any],
            let comments = result["comments"] as? [[String: Any]]
          {
            completion(Result.success(data: comments.flatMap{Comment(json: $0)}))
          } else {
            let error = NSError(domain: "Posting", code: 0, userInfo: [
              NSLocalizedDescriptionKey: "Couldn't get comments"
              ])
            completion(Result.fail(error: error))
          }
        case .failure(let error):
          completion(Result.fail(error: error as NSError))
        }
    }
  }
  
}

























