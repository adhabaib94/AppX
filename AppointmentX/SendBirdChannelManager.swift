//
//  SendBirdChannelManager.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 3/21/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import SendBirdSDK
import CoreData


class SendBirdChannelManager: NSObject, SBDConnectionDelegate, SBDChannelDelegate {
    
    // SendBird Required Variables
    
    var messages = [JSQMessage]()
    
    var last_message_received: Int64 = 0
    
    var last_cell = IndexPath()
    
    
    // SendBird Required Variables
    var connection_established = false
    
    var current_channel:SBDGroupChannel = SBDGroupChannel()
    
    // CoreData Variable
    
    var stored_messages: [NSManagedObject] = []
    var loaded_messages: Bool = false
    var last_received: [NSManagedObject] = []
    
    
    // Client Data
    
    var senderId : String!
    var senderDisplayName: String!
    
    // Notification
    let UPDATE_COLLECTION_VIEW = "UPDATE_COLL"
    let HIDE_LOADING_VIEW = "HIDE_LOADING_VIEW"
    let SHOW_LOADING_VIEW = "SHOW_LOADING_VIEW"
    let LOAD_COLLECTION_VIEW = "LOAD_COLL"
    let TYPING_SHOW = "IS_TYPING"
    let TYPING_HIDE = "NT_TYPING"
    
    
    // Setup Manager
    
    func setupManager(senderId: String , senderDisplayName: String){
        
        // BETA)
       
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        
        
        // (BETA) Setup SendBird Delegates
        
        SBDMain.add(self as SBDChannelDelegate, identifier: "user00" + "root")
        
        SBDMain.add(self as SBDConnectionDelegate, identifier: "user00" + "root" + "connect")

        
        // Fetch CoreData Stored Messages and Last Recieved Message
        self.fetchStoredMessages()
        self.fetchLastRecieved()
    
     
        
        
        
    }
    
    
    // CORE DATA FETCH STORED MESSAGES
    
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
                    
                    NotificationCenter.default.post(name: Notification.Name(self.LOAD_COLLECTION_VIEW), object: nil)
                    
                    // Connect To SendBird Server
                    self.channelConnectToSendBird()
                    self.loaded_messages = true
                    
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
                    NotificationCenter.default.post(name: Notification.Name(self.LOAD_COLLECTION_VIEW), object: nil)
                   

                    // Connect To SendBird Server
                    self.channelConnectToSendBird()
                    self.loaded_messages = true
                    
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }        }
            
        }
    }
    
    
    // CORE DATA FETCH LAST RECIEVED MESSAGE TIMESTAMP
    
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
        
        
        
        // ** NOTIFY CHATVC TO UPDATE COLLECTION VIEW **
        
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
    

    /**
     *  Connect to SendBird Server Authentication
     */
    
    func channelConnectToSendBird(){
        
        SBDMain.connect(withUserId:self.senderId, completionHandler: { (user, error) in
            SBDMain.registerDevicePushToken(SBDMain.getPendingPushToken()!, completionHandler: { (status, error) in
                print("ChatVC: Registered for push notfication")
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
                self.connection_established = true
               //(BETA) NOTIFY self.hideActivityView()
                NotificationCenter.default.post(name: Notification.Name(self.HIDE_LOADING_VIEW), object: nil)
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
        
        //(BETA) NOTIFY UPDATE COLLECTION VIEW
        NotificationCenter.default.post(name: Notification.Name(self.UPDATE_COLLECTION_VIEW), object: nil)
        
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
                
                
               //(BETA) NOTIFY UPDATE COLLECTIONVIEW
                NotificationCenter.default.post(name: Notification.Name(self.UPDATE_COLLECTION_VIEW), object: nil)
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
                         //(BETA) NOTIFY UPDATE COLLECTIONVIEW
                        NotificationCenter.default.post(name: Notification.Name(self.UPDATE_COLLECTION_VIEW), object: nil)
                        
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
        
        // (BETA) NOTIFY
        
        if sender.channelUrl == self.current_channel.channelUrl {
            let members = sender.getTypingMembers()
            
            if(members?.count == 1){
                if(members?[0].userId != self.senderId){
                NotificationCenter.default.post(name: Notification.Name(self.TYPING_SHOW), object: nil)
                    
                }
            }
            else{
                if(members?.count == 0){
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(self.TYPING_HIDE), object: nil)
                        
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
       //(BETA) NOTFIFY self.showActivityView()
         NotificationCenter.default.post(name: Notification.Name(self.SHOW_LOADING_VIEW), object: nil)
        self.connection_established = false
    }
    
    func didSucceedReconnection() {
        
        self.connection_established = true
        
        print("ChatVC: Auto reconnecting succeeded!")
        if(self.loaded_messages){
            self.getLastSentMessages()
          //(BETA) NOTFIFY  self.hideActivityView()
              NotificationCenter.default.post(name: Notification.Name(self.HIDE_LOADING_VIEW), object: nil)
        }
        
        
    }
    
    func didFailReconnection() {
        //(BETA) NOTFIFY self.showActivityView()
          NotificationCenter.default.post(name: Notification.Name(self.SHOW_LOADING_VIEW), object: nil)
        self.connection_established = false
        print("ChatVC: Auto reconnecting failed. You should call `connect` to reconnect to SendBird.")
        
    }
    
    

      
    
    
}
