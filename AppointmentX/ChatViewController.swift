//
//  ChatViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 2/26/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import SendBirdSDK


class ChatViewController: JSQMessagesViewController, SBDConnectionDelegate, SBDChannelDelegate {
    
    private var messages = [JSQMessage]();
    
    private var last_message_received: Int64 = 0
    
    var current_channel:SBDGroupChannel = SBDGroupChannel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //self.senderId = "user00"
        //self.senderDisplayName = "Yousef"
       self.senderId = "root"
       self.senderDisplayName = "Abdullah"
        
        
        SBDMain.add(self as SBDChannelDelegate, identifier: "user00" + "root")
        self.connectToSB()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushNotificationRecieved(notification:)), name: Notification.Name("chatMessageRecieved"), object: nil)
        
        
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // -------------- UICollectionView Functions ------------------ //
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.white
        } else {
            cell.textView.textColor = UIColor.black
        }
        
        
        return cell;
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with:UIColor.init(red: 15.0/255.0, green: 135.0/255.0, blue: 1, alpha: 1));
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with:UIColor.init(red: 230.0/255.0, green: 230.0/255.0, blue: 235.0/255.0, alpha: 1));
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt
        indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile-pic-2"), diameter: 30);
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile-pic"), diameter: 30);
        }
        
        
        
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    // ------------ Handle Messege Sent ------------ //
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text))
        
        self.current_channel.sendUserMessage(text) { (userMessage, error) in
            print("Messege Sent")
        }
    
        
        DispatchQueue.main.async {
            self.collectionView.reloadData();
            self.finishSendingMessage();
        }

        
       
        
    }
    
    
    // -------------- SendBird Functions ------------------ //
    
    func connectToSB(){
        SBDMain.connect(withUserId:self.senderId, completionHandler: { (user, error) in
            SBDMain.registerDevicePushToken(SBDMain.getPendingPushToken()!, completionHandler: { (status, error) in
                
            })
            self.createSBChannel()
        })
        
        
    }
    
    
    func createSBChannel(){
        
        let userIds = ["user00" , "root"]
        
        SBDGroupChannel.createChannel(withUserIds: userIds, isDistinct: true) { (channel, error) in
            if error != nil {
                NSLog("Error: %@", error!)
                return
            }
            else {
                self.current_channel = channel!
                self.getPreviousMessages()
            }
            
            
        }
        
        
    }
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        // Received a chat message
        
        self.last_message_received = message.createdAt
        
        let user_msg = (message as! SBDUserMessage)
        
        
        print("Message Recived")
        
        messages.append(JSQMessage(senderId: user_msg.sender?.userId, displayName: user_msg.sender?.nickname, text: user_msg.message));
        
        self.current_channel.markAsRead()
        
        
        DispatchQueue.main.async {
            self.collectionView.reloadData();
            self.finishReceivingMessage()
        }
        
    }
    
    
    func pushNotificationRecieved(notification: NSNotification){
        self.getLastSentMessages()
        
    }
    
    
    func getLastSentMessages(){
        let messageQuery = self.current_channel.createMessageListQuery()
        messageQuery?.loadNextMessages(fromTimestamp: self.last_message_received, limit: 100 , reverse: false, completionHandler: { (msgs, error) in
            if error != nil {
                NSLog("Error: %@", error!)
                return
            }
            else{
                for m in msgs! {
                    let user_msg = (m as! SBDUserMessage)
                    
                    if(user_msg.sender?.userId != self.senderId){
                        self.messages.append(JSQMessage(senderId: user_msg.sender?.userId, displayName: user_msg.sender?.nickname, text: user_msg.message));
                    }
                    
                }
                
                self.last_message_received = (msgs?[((msgs?.count)!-1)].createdAt)!
                
                self.current_channel.markAsRead()
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData();
                    self.finishReceivingMessage()
                }
                
            }
            
            // ...
        })
    }
    
    
    func getPreviousMessages(){
        
        let previousMessageQuery = self.current_channel.createPreviousMessageListQuery()
        previousMessageQuery?.loadPreviousMessages(withLimit: 100, reverse: false, completionHandler: { (msgs, error) in
            if error != nil {
                NSLog("Error: %@", error!)
                return
            }
            else{
                if(msgs?.count != 0 ){
                    self.messages.removeAll()
                    for m in msgs! {
                        let user_msg = (m as! SBDUserMessage)
                        self.messages.append(JSQMessage(senderId: user_msg.sender?.userId, displayName: user_msg.sender?.nickname, text: user_msg.message));
                    }
                    
                    self.last_message_received = (msgs?[((msgs?.count)!-1)].createdAt)!
                    
                    self.current_channel.markAsRead()
                    
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData();
                        self.finishReceivingMessage()
                    }
                }
            }
            
        })
        
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        // When read receipt has been updated
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        // When typing status has been updated
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        // When a new member joined the group channel
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        // When a member left the group channel
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        // When a new user entered the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        // When a new user left the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        // When a user is muted on the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {
        // When a user is unmuted on the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasBanned user: SBDUser) {
        // When a user is banned on the open channel
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {
        // When a user is unbanned on the open channel
    }
    
    func channelWasFrozen(_ sender: SBDOpenChannel) {
        // When the open channel is frozen
    }
    
    func channelWasUnfrozen(_ sender: SBDOpenChannel) {
        // When the open channel is unfrozen
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        // When a channel property has been changed
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        // When a channel has been deleted
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        // When a message has been deleted
    }
    
    
    
    
}