//
//  Post.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Alamofire
import SwiftyJSON
import Ax
import FirebaseStorage

struct Post {
  
//  var userWallId: String
//  var posterId: String
//  var dateCreated: Date
//  var pictureURLStrings: [String]
  
  var id: String
  var text: String
  var date: Date
  var commentCounter: Int
  var ownerId: String
  
  var ownerUsername: String?
  var ownerProfilePictureURL: String?
  
  var attachedImageURL: String?
}

extension Post {
  
  init?(json: [String: Any]) {
    guard
      let id = json["id"] as? String,
      let ownerId = json["ownerId"] as? String,
      let text = json["text"] as? String,
      let date = json["dateCreated"] as? Double,
      let commentCounter = json["commentCounter"] as? Int
    else {
      return nil
    }
    
    self.id = id
    self.text = text
    self.date = Date(timeIntervalSince1970: date * -1)
    self.ownerId = ownerId
    self.ownerUsername = json["ownerUsername"] as? String
    self.ownerProfilePictureURL = json["ownerProfilePictureURL"] as? String
    self.attachedImageURL = json["attachedImageURL"] as? String
    self.commentCounter = commentCounter
  }
  
}

extension Post {
  
  static let refDatabase = CSFirebase.refDatabase
  static let refDatabasePosts = refDatabase.child("post-by-user")
  static let refDatabaseComments = refDatabase.child("comments-by-post")
  
  static let refStorage = FIRStorage.storage().reference()
  
  // remove image
  static func removeImage(
    postId:String,
    completion: @escaping (NSError?) -> Void
  ) {
    
    let refStoragePosts = refStorage.child("posts")
    let refStoragePost = refStoragePosts.child(postId)
    let refStoragePostImage = refStoragePost.child("\(postId).jpg")
    
    refStoragePostImage.delete { (error) in
      completion(error as NSError?)
    }
    
  }
  
  static func saveImage(
    postId: String,
    image: UIImage,
    completion: @escaping (Result<String>) -> Void
  ) {
    
    let refStoragePosts = refStorage.child("posts")
    let refStoragePost = refStoragePosts.child(postId)
    
    let refStoragePostImage = refStoragePost.child("\(postId).jpg")
    
    if let imageData = UIImageJPEGRepresentation(image, 0.2) {
      refStoragePostImage.put(
        imageData,
        metadata: nil,
        completion: { (metadata: FIRStorageMetadata?, err: Error?) in
          if let err = err {
            completion(Result.fail(error: err as NSError))
          } else {
            if let pictureURL = metadata?.downloadURL()?.absoluteString {
              completion(Result.success(data: pictureURL))
            } else {
              let error = NSError(domain: "Posting", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "No URL string found."
              ])
              completion(Result.fail(error: error))
            }
          }
      })
    } else {
      let error = NSError(domain: "Posting", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Image not uploaded, try again please."
      ])
      completion(Result.fail(error: error))
    }
    
  }
  
  static func deletePost(
    wallOwnerId: String,
    postId: String,
    completion: @escaping (NSError?) -> Void
  ) {
    var deletePostFromPostsAndComments = [String: Any]()
    
    deletePostFromPostsAndComments["post-by-user/\(wallOwnerId)/\(postId)"] = NSNull()
    deletePostFromPostsAndComments["comments-by-post/\(postId)"] = NSNull()
    
    Ax.serial(tasks: [
      
      { done in
        removeImage(postId: postId, completion: { (error) in
          done(nil)
        })
      },
      
      { done in
        refDatabase.updateChildValues(deletePostFromPostsAndComments, withCompletionBlock: {
          (error: Error?, ref: FIRDatabaseReference) in 
          done(error as NSError?)
        });
      }
      
    ]) { (error) in
      completion(error)
    }
  }
  
  static func createPost(
    byPosterId posterId: String,
    wallOwnerId: String,
    text: String,
    attachedImage: UIImage?,
    date: Date,
    completion: @escaping (NSError?) -> Void
  ) {
    
    guard text.trimmingCharacters(in: CharacterSet.whitespaces).characters.count > 0 else
    {
      let error = NSError(domain: "Posting", code: 0, userInfo: [
        NSLocalizedDescriptionKey: "Please provide content before posting."
      ])
      completion(error)
      return
    }
    
    let refPost = refDatabasePosts
                        .child(wallOwnerId)
                        .childByAutoId()
    
    var values = [String: Any]()
    values["id"] = refPost.key
    values["ownerId"] = posterId
    values["text"] = text
    values["dateCreated"] = date.timeIntervalSince1970 * -1
    values["commentCounter"] = 0
    
    var attachedImageURLString: String?
    
    Ax.serial(tasks: [
      
      { done in
        if let image = attachedImage {
          saveImage(
            postId: refPost.key,
            image: image,
            completion: { (result) in
              
              switch result {
              case .success(let url):
                attachedImageURLString = url
              case .fail(_): break
              }
              
              done(nil)
          })
        } else {
          done(nil)
        }
      },
      
      { done in
        if let urlString = attachedImageURLString {
          values["attachedImageURL"] = urlString
        }
        
        refPost.setValue(values, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) in
          done(error as NSError?)
        })
      }
      
    ]) { (error) in
      completion(error)
    }

  }
  
  static func listenDeletesOnPosts(
    wallOwnerId: String,
    completion: @escaping (Post) -> Void
  ) -> UInt {
    let query = refDatabasePosts
                  .child(wallOwnerId)
    
    return query.observe(.childRemoved, with: { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if
          let json = snap.value as? [String: Any],
          let post = Post(json: json)
        {
          completion(post)
        }
      }
    })
  }
  
  static func listenChangesOnPosts(
    wallOwnerId: String,
//    fromTime time: Date,
    completion: @escaping (Post) -> Void
  ) -> UInt {
//    let timestamp = time.timeIntervalSince1970 * -1
    
    let query = refDatabasePosts
      .child(wallOwnerId)
//      .queryOrdered(byChild: "dateCreated")
//      .queryEnding(atValue: timestamp)
    
    return query.observe(.childChanged) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if
          let json = snap.value as? [String: Any],
          let post = Post(json: json)
        {
          completion(post)
        }
      }
    }
  }
  
  static func unlistenRecenPosts(
    wallOwnerId: String,
    time: Date,
    handlerId: UInt
  ) {
    let timestamp = time.timeIntervalSince1970 * -1
    
    let query = refDatabasePosts
      .child(wallOwnerId)
      .queryOrdered(byChild: "dateCreated")
      .queryEnding(atValue: timestamp)
    
    query.removeObserver(withHandle: handlerId)
  }
  
  static func listenRecentPosts(
    wallOwnerId: String,
    fromTime time: Date,
    completion: @escaping (Post) -> Void
  ) -> UInt {
    
    let timestamp = time.timeIntervalSince1970 * -1
    
    let query = refDatabasePosts
                  .child(wallOwnerId)
                  .queryOrdered(byChild: "dateCreated")
                  .queryEnding(atValue: timestamp)
    
    return query.observe(.childAdded) { (snap: FIRDataSnapshot) in
      if snap.exists() {
        if
          let json = snap.value as? [String: Any],
          let post = Post(json: json)
        {
          completion(post)
        }
      }
    }
  }
  
  static func getPostsOnce(
    byUserId userId: String,
    completion: @escaping (Result<[Post]>) -> Void
  ) {
    
    let url = "\(Constants.Server.stringURL)api/posts"
    
    var data = [String: Any]()
    data["userId"] = userId
    
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
             let posts = result["posts"] as? [[String: Any]]
          {
            completion(Result.success(data: posts.flatMap{Post(json: $0)}))
          } else {
            let error = NSError(domain: "Posting", code: 0, userInfo: [
              NSLocalizedDescriptionKey: "Couldn't get posts"
            ])
            completion(Result.fail(error: error))
          }
        case .failure(let error):
          completion(Result.fail(error: error as NSError))
        }
    }
  }
  
}
