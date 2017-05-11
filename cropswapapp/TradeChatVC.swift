//
//  TradeChatVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 4/20/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SVProgressHUD
import Ax

class TradeChatVC: JSQMessagesViewController {
  
  var dealId: String!
  var anotherUsername: String?
  var anotherUserId: String!
  var currentUserId: String!
  var anotherUser: User?
  var date: Date!
  
  var userImageView: UIImageView!
  
  var listenNewMessagesHandlerId: UInt = 0
  
  var jsqMessages = [JSQMessage]()

  let bubbleFactory = JSQMessagesBubbleImageFactory()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let currentUserId = User.currentUser?.uid {
      self.currentUserId = currentUserId
      self.senderId = currentUserId
      self.senderDisplayName = ""
    }
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 10, height: 17), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    
    setNavHeaderTitle(title: "Chat with \(anotherUsername ?? "")", color: UIColor.black)
    
    let userImageViewFrame = CGRect(x: 0, y: 0, width: 25, height: 25)
    userImageView = UIImageView(frame: userImageViewFrame)
    userImageView.backgroundColor = .lightGray
    userImageView.layer.cornerRadius = 25 / 2
    userImageView.layer.borderWidth = 1
    userImageView.layer.borderColor = UIColor.clear.cgColor
    userImageView.layer.masksToBounds = true
    userImageView.contentMode = .scaleAspectFit
    let userImageViewBar = UIBarButtonItem(customView: userImageView)
    navigationItem.rightBarButtonItem = userImageViewBar

    automaticallyScrollsToMostRecentMessage = true
    inputToolbar.contentView.leftBarButtonItem = nil
    collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
    collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    
    let buttonWidth = inputToolbar.contentView.leftBarButtonContainerView.frame.size.height
    let buttonHeight = inputToolbar.contentView.leftBarButtonContainerView.frame.size.height
    
    let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
    customButton.setImage(UIImage(named: "icon-button-send-message"), for: .normal)
    customButton.imageView?.contentMode = .scaleAspectFit
    
    inputToolbar.contentView.rightBarButtonItemWidth = buttonWidth
    inputToolbar.contentView.rightBarButtonItem = customButton
    
    inputToolbar.contentView.textView.font = UIFont(name: "Montserrat-Light", size: 15)
    inputToolbar.contentView.textView.textColor = UIColor.hexStringToUIColor(hex: "#484646")
  }
  
  func backButtonTouched() {
    dismiss(animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    CSNotification.clearChatNotification(withDealId: dealId, andUserId: currentUserId) { (error) in
      print(error)
    }
    
    Message.removeListenNewMessages(byDealId: dealId, date: date, handlerId: listenNewMessagesHandlerId)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    date = Date()
    
    
    
    listenNewMessagesHandlerId = Message.listenNewMessages(
      byDealId: dealId,
      date: date) { [weak self] (newMessage) in
        print("newmessage \(newMessage)")
        
        let jsqMessage = JSQMessage(senderId: newMessage.senderId, displayName: "", text: newMessage.text)
        self?.jsqMessages.append(jsqMessage!)
        
        DispatchQueue.main.async {
          self?.finishReceivingMessage(animated: true)
        }
    }
    
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }

    Ax.parallel(tasks: [
      
      { [weak self] done in
        User.getUser(byUserId: self?.anotherUserId) { (result) in
          switch result {
          case .success(let user):
            self?.anotherUser = user
            if let url = URL(string: user.profilePictureURL ?? "") {
              self?.userImageView.sd_setImage(with: url)
            }
          case .fail(let error):
            print(error)
          }
          
          done(nil)
        }
      },
      
      { [weak self] done in
        if let this = self {
          Message.getMessages(byDealId: this.dealId, completion: { (messages) in
            this.jsqMessages = messages.map { msg in
              let jsqMessage = JSQMessage(senderId: msg.senderId, displayName: "", text: msg.text)
              return jsqMessage!
            }
            
            DispatchQueue.main.async {
              this.finishReceivingMessage(animated: true)
            }
            
            done(nil)
          })
        }
      }
      
    ]) { (error) in
      SVProgressHUD.dismiss()
    }
  }
}

extension TradeChatVC {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return jsqMessages.count
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return jsqMessages[indexPath.row]
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = jsqMessages[indexPath.row]
    
    let outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.hexStringToUIColor(hex: "#f83f39"))
    let incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.hexStringToUIColor(hex: "#f0f2f5"))
    
    print(senderId)
    print(message.senderId)
    
    if senderId == message.senderId {
      return outgoingBubble
    } else {
      return incomingBubble
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    let message = jsqMessages[indexPath.row]
    
    cell.textView.font = UIFont(name: "Montserrat-Regular", size: 15)
    cell.textView.textAlignment = .center
    
    if message.senderId == senderId {
      cell.textView.textColor = UIColor.white
    } else {
      cell.textView.textColor = UIColor.black
    }
    
    return cell
  }
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
    Message.sendMessage(
      dealId: dealId,
      senderId: currentUserId,
      receiverId: anotherUserId,
      text: text) { (error) in
        print(error)
    }
    
    finishSendingMessage(animated: true)
  }
}








































