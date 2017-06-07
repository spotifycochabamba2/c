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
  
  
  var messageFont = UIFont(name: "Montserrat-Regular", size: 15)
  var statusMessageFont = UIFont(name: "Montserrat-Regular", size: 12)
  var timestampFont = UIFont(name: "Montserrat-Regular", size: 12)
  
  var attributesStringTopBubble = [String: Any]()
  var attributesStringStatusMessage = [String: Any]()
  var attributesStringTopCell = [String: Any]()
  
  var dealId: String?
  var anotherUsername: String?
  var anotherUserId: String!
  var currentUserId: String!
  var anotherUser: User?
  var date: Date!
  
  var updateInboxVC: () -> Void = { }
  
  // this screen could
  // used for chatting
  // on Trades or One on One (inbox)
  var usedForInbox = false
  
  var userImageView: UIImageView!
  
  var listenNewMessagesHandlerId: UInt = 0
  
  var jsqMessages = [(JSQMessage, String)]()
  var messagesDelivered = [String: Bool]()

  let bubbleFactory = JSQMessagesBubbleImageFactory()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    attributesStringTopBubble[NSForegroundColorAttributeName] = UIColor.black
    attributesStringTopBubble[NSFontAttributeName] = timestampFont
    
    attributesStringStatusMessage[NSForegroundColorAttributeName] = UIColor.darkGray
    attributesStringStatusMessage[NSFontAttributeName] = statusMessageFont
    
    attributesStringTopCell[NSForegroundColorAttributeName] = UIColor.black
    attributesStringTopCell[NSFontAttributeName] = messageFont
//    self.outgoingCellIdentifier = CustomMessagesCollectionViewCellOutgoing.cellReuseIdentifier()
//    self.outgoingMediaCellIdentifier = CustomMessagesCollectionViewCellOutgoing.mediaCellReuseIdentifier()
//
//    self.collectionView.register(CustomMessagesCollectionViewCellOutgoing.nib(), forCellWithReuseIdentifier: self.outgoingCellIdentifier)
//    self.collectionView.register(CustomMessagesCollectionViewCellOutgoing.nib(), forCellWithReuseIdentifier: self.outgoingMediaCellIdentifier)
//    
//    self.incomingCellIdentifier = CustomMessagesCollectionViewCellIncoming.cellReuseIdentifier()
//    self.incomingMediaCellIdentifier = CustomMessagesCollectionViewCellIncoming.mediaCellReuseIdentifier()
//    
//    self.collectionView.register(CustomMessagesCollectionViewCellIncoming.nib(), forCellWithReuseIdentifier: self.incomingCellIdentifier)
//    self.collectionView.register(CustomMessagesCollectionViewCellIncoming.nib(), forCellWithReuseIdentifier: self.incomingMediaCellIdentifier)
    
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
    
    if let dealId = dealId {
      if usedForInbox {
        if let userId = User.currentUser?.uid,
           let anotherUserId = anotherUserId {
          Inbox.clearInbox(
            ofUserId: userId,
            withUserId: anotherUserId,
            completion: { [weak self] in
              CSNotification.getNotificationsForAppIcon(userId: userId, completion: { (counter) in
                UIApplication.shared.applicationIconBadgeNumber = counter
              })
              self?.updateInboxVC()
          })
        }
      } else {
        CSNotification.clearChatNotification(withDealId: dealId, andUserId: currentUserId) { (error) in
          print(error)
        }
      }
      
      Message.removeListenNewMessages(byDealId: dealId, date: date, handlerId: listenNewMessagesHandlerId)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    date = Date()
    
    if let dealId = dealId {
      listenNewMessagesHandlerId = Message.listenNewMessages(
        byDealId: dealId,
        date: date) { [weak self] (newMessage) in
          self?.messagesDelivered[newMessage.id] = true
          
          let senderId = self?.senderId ?? newMessage.senderId
          
          if senderId != newMessage.senderId {
            let jsqMessage = JSQMessage(
              senderId: newMessage.senderId,
              senderDisplayName: "",
              date: newMessage.dateCreated,
              text: newMessage.text
            )
            
            self?.jsqMessages.append((jsqMessage!, newMessage.id))
          }
          
          DispatchQueue.main.async {
            self?.finishReceivingMessage(animated: true)
          }
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
            DispatchQueue.main.async {
              self?.setNavHeaderTitle(title: "Chat with \(user.name)", color: UIColor.black)
            }
            
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
        if let this = self,
           let dealId = this.dealId
        {
          Message.getMessages(byDealId: dealId, completion: { (messages) in
            this.jsqMessages = messages.map { msg in
              this.messagesDelivered[msg.id] = true
              let jsqMessage = JSQMessage(senderId: msg.senderId, senderDisplayName: "", date: msg.dateCreated, text: msg.text)
              return (jsqMessage!, msg.id)
            }
            
            DispatchQueue.main.async {
              this.finishReceivingMessage(animated: true)
            }
            
            done(nil)
          })
        } else {
          done(nil)
        }
      }
      
    ]) { [weak self] (error) in
      
      if let usedForInbox = self?.usedForInbox,
        usedForInbox {
        if let userId = User.currentUser?.uid,
          let anotherUserId = self?.anotherUserId {
          Inbox.clearInbox(
            ofUserId: userId,
            withUserId: anotherUserId,
            completion: {
              
          })
        }
      }
      DispatchQueue.main.async {
        SVProgressHUD.dismiss()
      }
    }
  }
}

extension TradeChatVC {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return jsqMessages.count
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return jsqMessages[indexPath.row].0
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = jsqMessages[indexPath.row].0
    
    let outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.hexStringToUIColor(hex: "#f83f39"))
    let incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.hexStringToUIColor(hex: "#f0f2f5"))
    
//    print(senderId)
//    print(message.senderId)
    
    if senderId == message.senderId {
      return outgoingBubble
    } else {
      return incomingBubble
    }
  }
  
 
  

  
  
  
//  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
//    var attributes = [String: Any]()
//    attributes[NSForegroundColorAttributeName] = UIColor.red
//    
//    let attributedString = NSAttributedString(string: "21:00", attributes: attributes)
//    return attributedString
//  }
 
  
  // CELL TOP LABEL
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    let message = jsqMessages[indexPath.row].0
    
    let attributedString = NSAttributedString(string: message.date.mediumDateString, attributes: attributesStringTopCell)
    return attributedString
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
    return 20
  }
  
  //  BUBBLE TOP LABEL
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    let message = jsqMessages[indexPath.row].0
    
    let attributedString = NSAttributedString(string: message.date.shortTimeString, attributes: attributesStringTopBubble)
    return attributedString
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    return 25
  }
  
  // CELL BOTTOM LABEL
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    let message = jsqMessages[indexPath.row].0
    let messageId = jsqMessages[indexPath.row].1
    let statusMessageBool = messagesDelivered[messageId] ?? true
    var statusMessageText = ""
    
    if message.senderId == senderId {
      if statusMessageBool {
        statusMessageText = "Sent"
      } else {
        statusMessageText = "Sending"
      }
    }
    
    print("new message: \(statusMessageText)")
    
    let attributedString = NSAttributedString(string: statusMessageText, attributes: attributesStringStatusMessage)
    return attributedString
  }
  
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
    return 25
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    let message = jsqMessages[indexPath.row].0
    
    cell.textView.font = messageFont
//    cell.cellTopLabel.font = timestampFont
//    cell.cellTopLabel.textColor = .black
    cell.cellTopLabel.textAlignment = .center
    
    if message.senderId == senderId {
      cell.textView.textColor = UIColor.white
      cell.textView.textAlignment = .right
      cell.messageBubbleTopLabel.textAlignment = .right
    } else {
      cell.textView.textColor = UIColor.black
      cell.textView.textAlignment = .left
      cell.messageBubbleTopLabel.textAlignment = .left
    }
    
    return cell
  }
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
    let jsqMessage = JSQMessage(senderId: senderId, senderDisplayName: "", date: date, text: text)
    
 
    
    if let dealId = dealId {
      let messageId = Message.sendMessage(
        dealId: dealId,
        senderId: currentUserId,
        receiverId: anotherUserId,
        text: text,
        date: date) { [weak self] (error) in
          print(error)
          
          if let this = self {
            if this.usedForInbox {
              Inbox.createOrUpdateInbox(
                fromUserId: this.currentUserId,
                toUserId: this.anotherUserId,
                text: text,
                date: Date(),
                inboxId: dealId,
                completion: { (error) in
                  print(error)
                  
                  //                  // test - probably to delete
                  //                  Message.sendMessagePushNotification(
                  //                    dealId: dealId,
                  //                    senderId: senderId,
                  //                    receiverId: this.anotherUserId,
                  //                    text: text,
                  //                    completion: { (_) in
                  //
                  //                  })
              })
            } else {
              // test
              Message.sendMessagePushNotification(
                dealId: dealId,
                senderId: senderId,
                receiverId: this.anotherUserId,
                text: text,
                completion: { (_) in
                  
              })
              
              // update user deal
              CSNotification.createOrUpdateChatNotification(
                withDealId: dealId,
                andUserId: this.anotherUserId,
                completion: { (error) in
                  print(error)
                }
              )
              
              // update notification
              CSNotification.saveOrUpdateTradeNotification(
                byUserId: this.anotherUserId,
                dealId: dealId,
                field: "chat",
                withValue: 1,
                completion: { (error) in
                  print(error)
              })
              // /test
            }
          }
      }
      
      jsqMessages.append((jsqMessage!, messageId))
      messagesDelivered[messageId] = false
    }
    
    finishSendingMessage(animated: true)
  }
}







































