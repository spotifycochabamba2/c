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
  
  var tradeListButtonWasTouchedOnChat: () -> Void = {}
  @IBOutlet weak var tradeListButton: UIButton!
  
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
  
  var transactionMethod: String?
  
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
  
  func userImageTopRightTapped() {
    performSegue(withIdentifier: Storyboard.TradeChatToProfileContainer, sender: nil)
  }
  
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
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userImageTopRightTapped))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    userImageView.addGestureRecognizer(tapGesture)
    
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
    
    tradeListButton.translatesAutoresizingMaskIntoConstraints = false
    collectionView.addSubview(tradeListButton)
    collectionView.bringSubview(toFront: tradeListButton)
    
    let height = NSLayoutConstraint(
      item: tradeListButton,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: 67
    )
    
    let width = NSLayoutConstraint(
      item: tradeListButton,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: 67
    )
    
    let bottom = NSLayoutConstraint(
      item: tradeListButton,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: view,
      attribute: .bottom,
      multiplier: 1,
      constant: -52
    )
    
    let right = NSLayoutConstraint(
      item: tradeListButton,
      attribute: .right,
      relatedBy: .equal,
      toItem: view,
      attribute: .right,
      multiplier: 1,
      constant: -8
    )
    
    view.addConstraints([height, width, bottom, right])
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
              CSNotification.getNotificationsForAppIcon(userId: userId, completion: { (error, counter) in
                UIApplication.shared.applicationIconBadgeNumber = counter
              })
              self?.updateInboxVC()
          })
        }
      } else {
        CSNotification.clearChatNotification(withDealId: dealId, andUserId: currentUserId) { (error) in

        }
      }
      
      Message.removeListenNewMessages(byDealId: dealId, date: date, handlerId: listenNewMessagesHandlerId)
    }
  }
  
  deinit {

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.TradeChatToFinalizeTrade {
      let vc = segue.destination as? FinalizeTradeVC
      vc?.didConfirmOffer = didConfirmOffer
    } else if segue.identifier == Storyboard.TradeChatToMakeDeal {
      let vc = segue.destination as? MakeDealVC
      vc?.transactionMethod = transactionMethod
      vc?.anotherOwnerId = anotherUserId
    } else if segue.identifier == Storyboard.TradeChatToProfileContainer {
      let nv = segue.destination as? UINavigationController
      let vc = nv?.viewControllers.first as? ProfileContainerVC

      vc?.currentUserId = anotherUserId
      vc?.currentUsername = anotherUsername
      vc?.showBackButton = true
      vc?.isReadOnly = true
    }
  }
  
  func didConfirmOffer(_ howFinalized: String) {
    transactionMethod = howFinalized
    performSegue(withIdentifier: Storyboard.TradeChatToMakeDeal, sender: nil)
  }
  
  
  @IBAction func tradeListButtonTouched() {
    guard let ownerId = anotherUserId else {
      let alert = UIAlertController(title: "Info", message: "Another User Id not provided.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    guard let ownerName = anotherUsername else {
      let alert = UIAlertController(title: "Info", message: "Another User Name not provided.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    guard let currenUserId = User.currentUser?.uid else {
      let alert = UIAlertController(title: "Info", message: "Current User Id not provided.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
      return
    }
    
    SVProgressHUD.show()
    Deal.anyActiveDeal(
      userOneId: currenUserId,
      userTwoId: ownerId) { [weak self] (result) in
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
        }
        
        switch result {
        case .success(let anyActive):
          if anyActive {
//
//            let alert = UIAlertController(title: "Error", message: "You already have a trade in progress with \(ownerName), Please go to your Trade List to see the trade.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            
//            self?.present(alert, animated: true)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissModals"), object: nil)
          } else {
            if ownerId != currenUserId {
              SVProgressHUD.show()
              
              Deal.canUserMakeADeal(fromUserId: currenUserId, toUserId: ownerId, completion: { [weak self] (hoursLeft) in
                DispatchQueue.main.async {
                  SVProgressHUD.dismiss()
                }

                
                if hoursLeft > 0 {
                  let alert = UIAlertController(title: "Error", message: "You already have a trade in progress with \(ownerName), Please wait \(hoursLeft) seconds before you submit a new request to \(ownerName) or wait for his response!", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "OK", style: .default))
                  
                  self?.present(alert, animated: true)
                } else {
                  
                  DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: Storyboard.TradeChatToFinalizeTrade, sender: nil)
                  }
                }
                })
            } else {
              let alert = UIAlertController(title: "Info", message: "Sorry you can't make a deal with yourself", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              self?.present(alert, animated: true)
            }
          }
        case .fail(let error):
          let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          DispatchQueue.main.async {
            self?.present(alert, animated: true)
          }
        }
        
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
            break
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
    cell.textView.textAlignment = .left
    
    if message.senderId == senderId {
      cell.textView.textColor = UIColor.white      
      cell.messageBubbleTopLabel.textAlignment = .right
    } else {
      cell.textView.textColor = UIColor.black
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
          
          if let this = self {
            if this.usedForInbox {
              Inbox.createOrUpdateInbox(
                fromUserId: this.currentUserId,
                toUserId: this.anotherUserId,
                text: text,
                date: Date(),
                inboxId: dealId,
                completion: { (error) in
                  
                  if error == nil {
                    // test - probably to delete
                    Message.sendMessagePushNotification(
                      dealId: dealId,
                      senderId: senderId,
                      receiverId: this.anotherUserId,
                      text: text,
                      completion: { (_) in
                        
                    })
                  }
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
                  
                }
              )
              
              // update notification
              CSNotification.saveOrUpdateTradeNotification(
                byUserId: this.anotherUserId,
                dealId: dealId,
                field: "chat",
                withValue: 1,
                completion: { (error) in

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







































