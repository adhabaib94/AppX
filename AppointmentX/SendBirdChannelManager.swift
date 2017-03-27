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
import SDWebImage


class SendBirdChannelManager: NSObject, SBDConnectionDelegate, SBDChannelDelegate {
    
    // SendBird Required Variables
    
    var messages = [JSQMessage]()
    
    var last_message_received: Int64 = 0
    
    var last_cell = IndexPath()
    
    
    
    // SendBird Required Variables
    var connection_established = false
    
    var current_channel:SBDGroupChannel = SBDGroupChannel()
    
    var unread_messages = 0
    
    var in_chat_controller = false
    
    // CoreData Variable
    
    var stored_messages: [NSManagedObject] = []
    var loaded_messages: Bool = false
    var loaded_messages_inserted: Bool = false
    var last_received: [NSManagedObject] = []
    
    var managedContext: NSManagedObjectContext?
    
    
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
    let SHOW_BANNER = "SHOW_BANNER"
    
    
    
    // Setup Manager
    
    func setupManager(senderId: String , senderDisplayName: String){
        
        // BETA) Setup Managed Context
        
        DispatchQueue.main.async {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            if #available(iOS 10.0, *) {
                
                self.managedContext =
                    appDelegate.persistentContainer.viewContext
            }
            else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                self.managedContext = appDelegate.managedObjectContext
                
            }
            
        }
        
        // BETA) SenderID and SenderDisplayName
        
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        
        
        // (BETA) Setup SendBird Delegates
        
        SBDMain.add(self as SBDChannelDelegate, identifier: "user00" + "root")
        
        SBDMain.add(self as SBDConnectionDelegate, identifier: "user00" + "root" + "connect")
        
        
        // Fetch CoreData Stored Messages and Last Recieved Message
        self.fetchLastRecieved()
        self.fetchStoredMessages()
        
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
    
    
    func update(senderId: String, senderDisplayName: String, content: String, date: Date, createdAt: Int64, messageSent: Bool, img: Data, isMedia: Bool, object: NSManagedObject) {
        
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
                
                
                
                // 3
                object.setValue(senderId, forKeyPath: "senderId")
                object.setValue(senderDisplayName, forKeyPath: "senderDisplayName")
                object.setValue(content, forKeyPath: "content")
                object.setValue(date, forKeyPath: "date")
                object.setValue(createdAt, forKeyPath: "createdAt")
                object.setValue(img, forKeyPath: "img")
                object.setValue(isMedia, forKeyPath: "isMedia")
                
                // 4
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                
                
            } else {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let entity =
                    NSEntityDescription.entity(forEntityName: "Message",
                                               in: managedContext)!
                
                
                // 3
                object.setValue(senderId, forKeyPath: "senderId")
                object.setValue(senderDisplayName, forKeyPath: "senderDisplayName")
                object.setValue(content, forKeyPath: "content")
                object.setValue(date, forKeyPath: "date")
                object.setValue(createdAt, forKeyPath: "createdAt")
                object.setValue(img, forKeyPath: "img")
                object.setValue(isMedia, forKeyPath: "isMedia")
                
                // 4
                do {
                    try managedContext.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
        }
        
    }
    
    func save(senderId: String, senderDisplayName: String, content: String, date: Date, createdAt: Int64, messageSent: Bool, img: Data, isMedia: Bool) {
        
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
                message.setValue(img, forKeyPath: "img")
                message.setValue(isMedia, forKeyPath: "isMedia")
                
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
                message.setValue(img, forKeyPath: "img")
                message.setValue(isMedia, forKeyPath: "isMedia")
                
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
            
        }
        
    }
    
    
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    
    
    func mediaReceived(senderID: String, senderName: String, url: String ,file: SBDFileMessage, index: Int) {
        
        let now = Date()
        
        print("Download Started")
        
        DispatchQueue.main.async() {
        /*
            
            let empty_data = Data()
            let empty_image = UIImage(data: empty_data)
            let empty_photo = JSQPhotoMediaItem(image: empty_image);
            empty_photo?.appliesMediaViewMaskAsOutgoing = false;
            
            
            self.messages.insert(JSQMessage(senderId: senderID, senderDisplayName: senderName, date: now, media: empty_photo), at: index+1);
            
            
            self.save(senderId: senderID,senderDisplayName: (file.sender?.nickname)!,content: "", date: now, createdAt: file.createdAt, messageSent: false, img: empty_data, isMedia: true)
            
            //(BETA) NOTIFY UPDATE COLLECTION VIEW
            NotificationCenter.default.post(name: Notification.Name(self.UPDATE_COLLECTION_VIEW), object: nil)
            
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
 
             */
        }
        
        
        
        let mediaURL = URL(string: url)
        getDataFromUrl(url: mediaURL!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                let photo = JSQPhotoMediaItem(image: image);
             
                photo?.appliesMediaViewMaskAsOutgoing = false;
        
                
                  /*
                let msg = self.stored_messages[index+1] as NSManagedObject
                
              
                self.update(senderId: senderID,senderDisplayName: senderName, content: "", date: now, createdAt: file.createdAt, messageSent: false, img: data, isMedia: true, object: msg)
                
 
                
                
                self.messages[index+1] = JSQMessage(senderId: senderID, senderDisplayName: senderName, date: now, media: photo)
                 */
                
                self.messages.insert(JSQMessage(senderId: senderID, senderDisplayName: senderName, date: now, media: photo), at: index+1)
                
                self.save(senderId: senderID, senderDisplayName: senderName, content: "", date: now, createdAt: file.createdAt, messageSent: false, img: data, isMedia: true)
              
                //(BETA) NOTIFY UPDATE COLLECTION VIEW
                NotificationCenter.default.post(name: Notification.Name(self.UPDATE_COLLECTION_VIEW), object: nil)
                
                
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                
            }
        }
        
    }
    
    
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        
        
        // Update MainViewController Banner
        
        if(!self.in_chat_controller){
            self.unread_messages = self.unread_messages + 1
            print("SendBirdChannelManager: Banner Messages \(self.unread_messages)\n")
            NotificationCenter.default.post(name: Notification.Name(self.SHOW_BANNER), object: nil)
        }
        
        
        if( self.last_message_received < message.createdAt){
            self.last_message_received = message.createdAt
        }
        
        
        print("ChatVC: Message Recived")
        
        
        
        DispatchQueue.main.async {
            
            let now = Date()
            
            
            
            if let file = message as? SBDFileMessage {
                
                var index = self.messages.count - 1
                
                if(index < 0 ){
                    index = 0
                }
                
                self.mediaReceived(senderID: (file.sender?.userId)!, senderName: (file.sender?.nickname)!, url: file.url, file: file, index: index)
                
            }
            else{
                let user_msg = (message as! SBDUserMessage)
                self.messages.append(JSQMessage(senderId: user_msg.sender?.userId, senderDisplayName: user_msg.sender?.nickname, date: now , text: user_msg.message));
                
                self.current_channel.markAsRead()
                
                // Beta -> Store to CoreData
                let nil_data = Data()
                self.save(senderId: (user_msg.sender?.userId)!,senderDisplayName: (user_msg.sender?.nickname)!,content: user_msg.message!, date: now, createdAt: message.createdAt, messageSent: false, img: nil_data, isMedia: false)
                
                //(BETA) NOTIFY UPDATE COLLECTION VIEW
                NotificationCenter.default.post(name: Notification.Name(self.UPDATE_COLLECTION_VIEW), object: nil)
                
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                
                
                
                
            }
            
            
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
                
                if(!self.in_chat_controller && msgs?.count != 0){
                    self.unread_messages += (msgs?.count)!
                    NotificationCenter.default.post(name: Notification.Name(self.SHOW_BANNER), object: nil)
                    print("SendBirdChannelManager: Banner \(self.unread_messages)\n")
                }
                
                for m in msgs! {
                    
                    
                    if let file = m as? SBDFileMessage {
                        
                        var index = self.messages.count - 1
                        
                        if(index < 0 ){
                            index = 0
                        }
                        
                        self.mediaReceived(senderID: (file.sender?.userId)!, senderName: (file.sender?.nickname)!, url: file.url, file: file, index: index)
                        
                    }else{
                        let user_msg = (m as! SBDUserMessage)
                        
                        if(user_msg.sender?.userId != self.senderId){
                            self.messages.append(JSQMessage(senderId: user_msg.sender?.userId, displayName: user_msg.sender?.nickname, text: user_msg.message));
                            
                            let now = Date()
                            
                            let nil_data = Data()
                            
                            // Beta -> Store to CoreData
                            self.save(senderId: (user_msg.sender?.userId)!,senderDisplayName: (user_msg.sender?.nickname)!,content: user_msg.message!, date: now , createdAt: user_msg.createdAt, messageSent: false, img: nil_data, isMedia: false)
                        }
                        
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
     
     */
    
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
