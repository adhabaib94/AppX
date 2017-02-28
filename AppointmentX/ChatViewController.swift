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
    
    private var last_cell = IndexPath()
    
    private var connection_established = false
    
    
    var current_channel:SBDGroupChannel = SBDGroupChannel()
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = "user00"
    self.senderDisplayName = "Yousef"
       // self.senderId = "root"
       // self.senderDisplayName = "Abdullah"
        
        SBDMain.add(self as SBDChannelDelegate, identifier: "user00" + "root")
        self.connectToSB()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushNotificationRecieved(notification:)), name: Notification.Name("chatMessageRecieved"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshChatState), name: Notification.Name("willEnterForeGround"), object: nil)
        
        self.automaticallyScrollsToMostRecentMessage = true
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor.init(red: 6.0/255.0, green: 190.0/255.0, blue: 189.0/255.0, alpha: 1), for: UIControlState.normal)
        self.inputToolbar.contentView.rightBarButtonItem.titleLabel?.font = UIFont(name: "Source Sans Pro", size: 16)
        
        self.inputToolbar.contentView.textView.font = UIFont(name: "Source Sans Pro", size: 16)
        
        
        self.collectionView.backgroundColor = UIColor.clear
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        
        imageView.image = UIImage(named: "background")
        
        imageView.alpha = 0.12
   
        self.view.insertSubview(imageView, at: 0)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.current_channel.endTyping()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // -------------- UICollectionView Functions ------------------ //
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 7 == 0 && self.messages[indexPath.item].senderId != self.senderId) {
            let message = self.messages[indexPath.item]
            let now = Date()
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: now)
        }
        
        return nil
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat{
        
        return 3
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 7 == 0 && self.messages[indexPath.item].senderId != self.senderId) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 2.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return 0
        }
        else{
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        
        if message.senderId == self.senderId {
            return nil
        } else {
            return NSAttributedString(string: message.senderDisplayName)
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.white
            cell.textView.font = UIFont(name: "Source Sans Pro", size: 17)
        } else {
            cell.textView.textColor = UIColor.black
            cell.textView.font = UIFont(name: "Source Sans Pro", size: 17)
        }
        
        return cell;
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with:UIColor.init(red: 6.0/255.0, green: 190.0/255.0, blue: 189.0/255.0, alpha: 1));
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
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        
 
        
        self.messages.append(JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: date , text: text))
        
        self.current_channel.sendUserMessage(text) { (userMessage, error) in
            print("Messege Sent")
        }
        
        
        DispatchQueue.main.async {
            self.finishSendingMessage(animated: true)
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
        
        let date = Date(timeIntervalSince1970: (TimeInterval(message.createdAt)))
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+3") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        
        let now = Date()
        
        messages.append(JSQMessage(senderId: user_msg.sender?.userId, senderDisplayName: user_msg.sender?.nickname, date: now , text: user_msg.message));
        
        self.current_channel.markAsRead()
        
        
        DispatchQueue.main.async {
            self.finishReceivingMessage()
        }
        
    }
    
    
    func pushNotificationRecieved(notification: NSNotification){
        //self.getLastSentMessages()
        
    }
    
    
    func refreshChatState(){
        
        if(self.connection_established){
            self.getLastSentMessages()
        }
        
    }
    
    
    
    func getLastSentMessages(){
        let messageQuery = self.current_channel.createMessageListQuery()
        messageQuery?.loadNextMessages(fromTimestamp: self.last_message_received, limit: 100 , reverse: false, completionHandler: { (msgs, error) in
            if error != nil {
                NSLog("Error: %@", error!)
                return
                self.getLastSentMessages()
            }
            else{
                
            
                for m in msgs! {
                    let user_msg = (m as! SBDUserMessage)
                    
                    if(user_msg.sender?.userId != self.senderId){
                        self.messages.append(JSQMessage(senderId: user_msg.sender?.userId, displayName: user_msg.sender?.nickname, text: user_msg.message));
                    }
                    
                }
                
                if(msgs?.count != 0){
    
                    self.last_message_received = (msgs?[((msgs?.count)!-1)].createdAt)!
                    self.current_channel.markAsRead()
                    
                }
                
                
                DispatchQueue.main.async {
                    self.finishReceivingMessage()
                }
                
            }

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
                        self.finishReceivingMessage()
                        self.connection_established = true
                        
                    }
                }
            }
            
        })
        
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        // When read receipt has been updated
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        if(textView.text != "" ){
            self.current_channel.startTyping()
        }
        else{
            self.current_channel.endTyping()
        }
        
    }
    
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        self.current_channel.endTyping()
    }
    
    
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
        
        if sender.channelUrl == self.current_channel.channelUrl {
            let members = sender.getTypingMembers()
            
            if(members?.count == 1){
                if(members?[0].userId != self.senderId){
                    
                    DispatchQueue.main.async {
                        self.showTypingIndicator = true
                        self.scrollToBottom(animated: true)
                        self.collectionView.reloadData()
                        
                    }
                    
                }
            }
            else{
                if(members?.count == 0){
                    DispatchQueue.main.async {
                        self.showTypingIndicator = false
                        self.scrollToBottom(animated: true)
                        self.collectionView.reloadData()
                        
                    }
                }
            }
            
            // Refresh typing status.
        }
        
        
        
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


typealias UnixTime = Int

extension UnixTime {
    private func formatType(form: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    var dateFull: Date {
        return Date(timeIntervalSince1970: Double(self))
    }
    var toHour: String {
        return formatType(form: "HH:mm").string(from: dateFull)
    }
    var toDay: String {
        return formatType(form: "MM/dd/yyyy").string(from: dateFull)
    }
}

