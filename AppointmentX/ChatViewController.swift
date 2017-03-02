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
import CoreData


class ChatViewController: JSQMessagesViewController, SBDConnectionDelegate, SBDChannelDelegate {
    
    // UI Variable Declaration
    
    private var messages = [JSQMessage]();
    
    private var last_message_received: Int64 = 0
    
    private var last_cell = IndexPath()
    
    
    
    // SendBird Required Variables
    private var connection_established = false
    
    var current_channel:SBDGroupChannel = SBDGroupChannel()
    
    // CoreData Variable
    
    var stored_messages: [NSManagedObject] = []
    var loaded_messages: Bool = false
    var last_received: [NSManagedObject] = []
    
    
    // UI connection indicator
    
    var activityCoreView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    
    // --------------------------------------- UIViewController Functions -----------------------------------//
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initalize UIActivity Indicator
        self.showActivityView()
        
        // Initialize User/ Display Name
        if #available(iOS 10.0, *) {
            
            
            self.senderId = "user00"
            self.senderDisplayName = "Yousef"
        }
            
        else{
            
            self.senderId = "root"
            self.senderDisplayName = "Abdullah"
            
        }
        
        
        // Setup SendBird Delegates
        
        SBDMain.add(self as SBDChannelDelegate, identifier: "user00" + "root")
        
        SBDMain.add(self as SBDConnectionDelegate, identifier: "user00" + "root" + "connect")
        
        
        // Setup JSQMessageViewController UI Elements
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor.init(red: 6.0/255.0, green: 190.0/255.0, blue: 189.0/255.0, alpha: 1), for: UIControlState.normal)
        self.inputToolbar.contentView.rightBarButtonItem.titleLabel?.font = UIFont(name: "Source Sans Pro", size: 16)
        
        self.inputToolbar.contentView.textView.font = UIFont(name: "Source Sans Pro", size: 16)
        
        self.collectionView.backgroundColor = UIColor.clear
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width , height: screenSize.height))
        
        imageView.image = UIImage(named: "background")
        
        imageView.alpha = 0.09
        
        self.view.insertSubview(imageView, at: 1)
        
        self.automaticallyScrollsToMostRecentMessage = true
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Trash-50"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(ChatViewController.clearStoredMessages), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(item1, animated: true)
        
        
        // Core Data Testing
        
        self.fetchLastRecieved()
        self.fetchStoredMessages()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        // Insure User Updates Status to endTyping
        self.current_channel.endTyping()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Setup Status bar to Light Skin
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    // ---------------------------------- JSQMessageViewController Functions --------------------------------//
    
    
    /**
     * Returns the number of messages in UICollectionView (messages)
     */
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    
    /**
     *  Setups the Date Label every such messages
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        if (indexPath.item % 7 == 0 && self.messages[indexPath.item].senderId != self.senderId) {
            _ = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: messages[indexPath.item].date)
        }
        
        return nil
    }
    
    /**
     *  Returns the bottom height for each message bubble cell
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat{
        
        return 3
        
    }
    
    /**
     * Returns the top height for each cell
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.item % 7 == 0 && self.messages[indexPath.item].senderId != self.senderId) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 2.0
    }
    
    /**
     *  Setups each message bubble top height
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return 0
        }
        else{
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
    }
    
    /**
     *  Setups each message bubble with Display Name above it
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        
        if message.senderId == self.senderId {
            return nil
        } else {
            return NSAttributedString(string: message.senderDisplayName)
        }
        
        
    }
    
    /**
     *  Setups up the message text bubble color and font
     */
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
    
    /**
     *  Setups the message bubble color and cell setup
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with:UIColor.init(red: 6.0/255.0, green: 190.0/255.0, blue: 189.0/255.0, alpha: 1));
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with:UIColor.init(red: 230.0/255.0, green: 230.0/255.0, blue: 235.0/255.0, alpha: 1));
        }
        
    }
    
    /**
     *  Setups up each message bubble avatar
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt
        indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
            return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile-pic-2"), diameter: 30);
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile-pic"), diameter: 30);
        }
        
        
        
    }
    
    
    /**
     *  Returns each message for each bubble
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    /**
     *  EventHandler every time user attempts to send message
     */
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        // Play Sent Sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // Append new message in message queue
        self.messages.append(JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: date , text: text))
        
        // Save to CoreDatata
        self.save(senderId: self.senderId ,senderDisplayName: self.senderDisplayName,content: text, date: date, createdAt: -1 , messageSent: true)
        
        // Send Message Through Sendbird
        self.current_channel.sendUserMessage(text) { (userMessage, error) in
            print("Messege Sent")
        }
        
        // Update UICollectionView and Dismiss TextView
        DispatchQueue.main.async {
            self.finishSendingMessage(animated: true)
        }
        
        
    }
    
    
    // --------------------------------------- SBDChannelDelegate Functions -----------------------------------//
    
    /**
     *  Connect to SendBird Server Authentication
     */
    
    func channelConnectToSendBird(){
        SBDMain.connect(withUserId:self.senderId, completionHandler: { (user, error) in
            SBDMain.registerDevicePushToken(SBDMain.getPendingPushToken()!, completionHandler: { (status, error) in
                
            })
            print("ChatVC: Connected to Sendbird Server -> Authentication Complete")
            self.channelCreateNewChannel()
        })
        
        
    }
    
    /**
     *  Create new Channel if channel does not exists
     */
    func channelCreateNewChannel(){
        
        let userIds = ["user00" , "root"]
        
        SBDGroupChannel.createChannel(withUserIds: userIds, isDistinct: true) { (channel, error) in
            if error != nil {
                NSLog("Error: %@", error!)
                return
            }
            else {
                print("ChatVC: Channel Created/Entered")
                self.current_channel = channel!
                self.getLastSentMessages()
                self.hideActivityView()
            }
            
            
        }
        
        
    }
    
    /**
     *  Recieved New Message from Channel
     */
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        
        self.last_message_received = message.createdAt
        
        let user_msg = (message as! SBDUserMessage)
        
        print("ChatVC: Message Recived")
        
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        
        let now = Date()
        
        messages.append(JSQMessage(senderId: user_msg.sender?.userId, senderDisplayName: user_msg.sender?.nickname, date: now , text: user_msg.message));
        
        self.current_channel.markAsRead()
        
        // Beta -> Store to CoreData
        self.save(senderId: (user_msg.sender?.userId)!,senderDisplayName: (user_msg.sender?.nickname)!,content: user_msg.message!, date: now, createdAt: message.createdAt, messageSent: false)
        
        DispatchQueue.main.async {
            self.finishReceivingMessage()
        }
        
    }
    
    /**
     *  Insure Retreiving new Messages if Connected
     */
    func refreshChatState(){
        
        if(self.connection_established && self.loaded_messages){
            self.getLastSentMessages()
        }
        
    }
    
    /**
     *  Get Unread messages from SendBird Server
     */
    
    func getLastSentMessages(){
        
        
        if(self.last_message_received == 0){
            if(self.last_received.count > 0 ){
                let createdAt = self.last_received[self.last_received.count - 1]
                self.last_message_received = createdAt.value(forKey: "createdAt") as! Int64
            }
        }
        
        
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
                        
                        let now = Date()
                        
                        // Beta -> Store to CoreData
                        self.save(senderId: (user_msg.sender?.userId)!,senderDisplayName: (user_msg.sender?.nickname)!,content: user_msg.message!, date: now , createdAt: user_msg.createdAt, messageSent: false)
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
    
    
    /**
     *  Get All Messages from Channel from Sendbird Server
     */
    func getPreviousMessages(){
        
        let previousMessageQuery = self.current_channel.createPreviousMessageListQuery()
        previousMessageQuery?.loadPreviousMessages(withLimit: 10, reverse: false, completionHandler: { (msgs, error) in
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
    
    /**
     *  When read receipt has been updated
     */
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        print("ChatVC: read recipt has been updated")
    }
    
    
    
    /**
     *  Did Recieve Update Typing Status Event Handler
     */
    
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
    
    
    // When a new member joined the group channel
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        if(self.connection_established && self.loaded_messages){
            self.getLastSentMessages()
            
        }
    }
    
    // When a member left the group channel
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        print("ChatVC: User entered Chanel!")
        if(self.connection_established && self.loaded_messages){
            self.getLastSentMessages()
            
        }
    }
    
    // When a new user left the open channel
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        
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
    
    
    
    // --------------------------------------- SBDConnectionDelegate Functions ------------------------------//
    
    func didStartReconnection() {
        print("ChatVC: Attemping to reconnect!")
        self.showActivityView()
        self.connection_established = false
    }
    
    func didSucceedReconnection() {
        
        self.connection_established = true
        
        print("ChatVC: Auto reconnecting succeeded!")
        if(self.loaded_messages){
            self.getLastSentMessages()
            self.hideActivityView()
        }
        
        
    }
    
    func didFailReconnection() {
        self.showActivityView()
        self.connection_established = false
        print("ChatVC: Auto reconnecting failed. You should call `connect` to reconnect to SendBird.")
        
    }
    
    
    
    // ---------------------------------------------- Helper Functions --------------------------------------//
    
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        
        if(self.connection_established){
            if(textView.text != "" ){
                self.current_channel.startTyping()
            }
            else{
                self.current_channel.endTyping()
            }
        }
    }
    
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        
        if(self.connection_established){
            self.current_channel.endTyping()
        }
    }
    
    
    func save(senderId: String, senderDisplayName: String, content: String, date: Date, createdAt: Int64, messageSent: Bool) {
       
        DispatchQueue.main.async {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        if #available(iOS 10.0, *) {
            
            
            // (A) Save Message Entity
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            // 2
            let entity =
                NSEntityDescription.entity(forEntityName: "Message",
                                           in: managedContext)!
            
            let message = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
            
            // 3
            message.setValue(senderId, forKeyPath: "senderId")
            message.setValue(senderDisplayName, forKeyPath: "senderDisplayName")
            message.setValue(content, forKeyPath: "content")
            message.setValue(date, forKeyPath: "date")
            message.setValue(createdAt, forKeyPath: "createdAt")
            
            // 4
            do {
                try managedContext.save()
                self.stored_messages.append(message)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            // (B) Set Last Message Created At
            if(!messageSent){
                self.last_message_received = createdAt
                
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                
                // 2
                let entity =
                    NSEntityDescription.entity(forEntityName: "LastReceived",
                                               in: managedContext)!
                
                let message = NSManagedObject(entity: entity,
                                              insertInto: managedContext)
                
                // 3
                message.setValue(self.last_message_received, forKeyPath: "createdAt")
   
                // 4
                do {
                    try managedContext.save()
                    self.last_received.append(message)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
            
            
        } else {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let entity =
                NSEntityDescription.entity(forEntityName: "Message",
                                           in: managedContext)!
            
            let message = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
            
            // 3
            message.setValue(senderId, forKeyPath: "senderId")
            message.setValue(senderDisplayName, forKeyPath: "senderDisplayName")
            message.setValue(content, forKeyPath: "content")
            message.setValue(date, forKeyPath: "date")
            message.setValue(createdAt, forKeyPath: "createdAt")
            
            // 4
            do {
                try managedContext.save()
                self.stored_messages.append(message)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            // (B) Set Last Message Created At
            if(!messageSent){
                self.last_message_received = createdAt
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let entity =
                    NSEntityDescription.entity(forEntityName: "LastReceived",
                                               in: managedContext)!
                
                let message = NSManagedObject(entity: entity,
                                              insertInto: managedContext)
                
                message.setValue(self.last_message_received, forKeyPath: "createdAt")

                do {
                    try managedContext.save()
                    self.last_received.append(message)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }

                
            }
            
            
        }
        
        }
    }
    
    
    func fetchStoredMessages(){
        //1
        DispatchQueue.main.async {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        if #available(iOS 10.0, *) {
            let managedContext =
                appDelegate.persistentContainer.viewContext
            //2
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: "Message")
            
            //3
            do {
                self.stored_messages = try managedContext.fetch(fetchRequest)
                
                self.loadStoredMessagesIntoUICollectionView()
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
            
            do {
                let results =
                    try managedContext.fetch(fetchRequest)
                self.stored_messages = results as! [NSManagedObject]
                self.loadStoredMessagesIntoUICollectionView()
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }        }
        
        }
    }
    
    func fetchLastRecieved(){
        //1
        DispatchQueue.main.async {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            if #available(iOS 10.0, *) {
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                //2
                let fetchRequest =
                    NSFetchRequest<NSManagedObject>(entityName: "LastReceived")
                
                //3
                do {
                    self.last_received = try managedContext.fetch(fetchRequest)
                    
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LastReceived")
                
                do {
                    let results =
                        try managedContext.fetch(fetchRequest)
                    self.last_received = results as! [NSManagedObject]

                    
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }        }
            
        }
    }
    
    
    func loadStoredMessagesIntoUICollectionView(){
        
        var createdAtDates = [Int64]()
        
        for msg in stored_messages {
            
            
            print("SenderDisplayName: " + String(describing: msg.value(forKey: "senderDisplayName")!) + "\n")
            print("\tSenderID: " + String(describing: msg.value(forKey: "senderId")!) + "\n")
            print("\tContent: " + String(describing: msg.value(forKey: "content")!) + "\n\n")
            print("\tContent: " + String(describing: msg.value(forKey: "date")! as! Date) + "\n\n")
            
            messages.append(JSQMessage(senderId: String(describing: msg.value(forKey: "senderId")!), senderDisplayName: String(describing: msg.value(forKey: "senderDisplayName")!) , date:( msg.value(forKey: "date")! as! Date) , text: String(describing: msg.value(forKey: "content")!)));
            
            let current_date = msg.value(forKey: "createdAt") as! Int64
            let sender = String(describing: msg.value(forKey: "senderId")!)
            
            if(sender != self.senderId){
                createdAtDates.append(current_date)
            }
            
        }
        
        
        
        DispatchQueue.main.async {
            self.finishReceivingMessage()
        }
        
        
        if(createdAtDates.count > 0){
            self.last_message_received = createdAtDates[createdAtDates.count - 1]
        }
        else{
            self.last_message_received = 0
        }
        
        // Connect To SendBird Server
        self.channelConnectToSendBird()
        self.loaded_messages = true
        
        
    }
    
    
    
    
    
    func clearStoredMessages(){
        
        DispatchQueue.main.async {
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            // Create Fetch Request
            
            if #available(iOS 10.0, *) {
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                
                // Create Batch Delete Request
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try managedContext.execute(batchDeleteRequest)
                    
                } catch {
                    // Error Handling
                }
                
            } else {
                 let managedContext = appDelegate.managedObjectContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                
                // Create Batch Delete Request
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try managedContext.execute(batchDeleteRequest)
                    
                } catch {
                    // Error Handling
                }
            }
            
            self.messages.removeAll()
            self.finishReceivingMessage()
        }
        
    }
    
    
    
    
    func showActivityView(){
        DispatchQueue.main.async {
            self.activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            let connectingLabel = UILabel.init(frame: CGRect(x: 30, y: 0, width: 100, height: 22))
            connectingLabel.text = "Connecting"
            connectingLabel.font =  UIFont(name: "Source Sans Pro", size: 19)
            self.activityCoreView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 22))
            self.activityCoreView.addSubview(connectingLabel)
            self.activityCoreView.addSubview(self.activityIndicator)
            self.navigationItem.titleView = self.activityCoreView
            self.activityIndicator.startAnimating()

            
        }
        
        
        
        
    }
    
    func hideActivityView(){
        
        DispatchQueue.main.async {
            self.navigationItem.titleView = nil
            self.activityIndicator.stopAnimating()
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
            self.inputToolbar.contentView.rightBarButtonItem.isUserInteractionEnabled = true
            self.inputToolbar.contentView.textView.isEditable = true
        }
        
        
    }
    
    
}






