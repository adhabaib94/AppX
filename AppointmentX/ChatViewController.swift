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
import Photos


class ChatViewController: JSQMessagesViewController, SBDConnectionDelegate, SBDChannelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UI Variable Declaration
    
    
    private var last_cell = IndexPath()
    
    
    // UI connection indicator
    
    var activityCoreView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    let picker = UIImagePickerController();
    
    var selected_image: UIImage!
    
    
    
    // MainViewController
    
    var mainViewController : MainViewController!
    
    
    // Notification
    let LOAD_COLLECTION_VIEW = "LOAD_COLL"
    let UPDATE_COLLECTION_VIEW = "UPDATE_COLL"
    let HIDE_LOADING_VIEW = "HIDE_LOADING_VIEW"
    let SHOW_LOADING_VIEW = "SHOW_LOADING_VIEW"
    let TYPING_SHOW = "IS_TYPING"
    let TYPING_HIDE = "NT_TYPING"
    
    
    // --------------------------------------- UIViewController Functions -----------------------------------//
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (BETA) Initialize User/ Display Name
        if #available(iOS 10.0, *) {
            
            
            self.senderId = "user00"
            self.senderDisplayName = "Yousef"
        }
            
        else{
            
            self.senderId = "root"
            self.senderDisplayName = "Abdullah"
            
        }
        

        self.navigationItem.hidesBackButton = true;
        
        self.picker.delegate = self
        
        self.mainViewController.chatManager.in_chat_controller = true
        self.mainViewController.chatManager.unread_messages = 0
        self.mainViewController.hideMessageBanner()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showActivityView), name: Notification.Name(self.SHOW_LOADING_VIEW), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideActivityView), name: Notification.Name(self.HIDE_LOADING_VIEW), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadStoredMessagesIntoUICollectionView), name: Notification.Name(self.LOAD_COLLECTION_VIEW), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.recievedMessage), name: Notification.Name(self.UPDATE_COLLECTION_VIEW), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showTyping), name: Notification.Name(self.TYPING_SHOW), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideTyping), name: Notification.Name(self.TYPING_HIDE), object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshChatViewControllerCollectionView),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)

        
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
        
        imageView.alpha = 0.03
        
        self.view.insertSubview(imageView, at: 0)
        
        self.automaticallyScrollsToMostRecentMessage = true
        
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "phone_icon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(ChatViewController.clearStoredMessages), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(item1, animated: true)
        
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(named: "Back-50"), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        btn2.addTarget(self, action: #selector(ChatViewController.onClickBack), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        self.navigationItem.setLeftBarButton(item2, animated: true)
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.hideActivityView()
        
        self.mainViewController.chatManager.in_chat_controller = false
        self.mainViewController.chatManager.unread_messages = 0
        self.mainViewController.chatManager.loaded_messages_inserted = false
        
        // Insure User Updates Status to endTyping
        // self.current_channel.endTyping()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshChatViewControllerCollectionView()
        
    }
    
    
    func refreshChatViewControllerCollectionView(){
        
        self.navigationController?.navigationBar.isHidden = false

        if(!self.mainViewController.chatManager.connection_established){
            self.showActivityView()
             self.mainViewController.chatManager.messages.removeAll()
            self.mainViewController.chatManager.setupManager(senderId: self.senderId, senderDisplayName: self.senderDisplayName )
            self.mainViewController.chatManager.in_chat_controller = true
            self.mainViewController.chatManager.unread_messages = 0
            self.mainViewController.hideMessageBanner()
            
        }
        else{
            /*
            if(!self.mainViewController.chatManager.loaded_messages_inserted){
                self.mainViewController.chatManager.messages.removeAll()
                self.loadStoredMessagesIntoUICollectionView()
                
                
            }
            */
        }

    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Setup Status bar to Light Skin
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    func onClickBack()
        
    {
        
        self.hideActivityView()
        
        self.mainViewController.chatManager.in_chat_controller = false
        self.mainViewController.chatManager.unread_messages = 0
        self.mainViewController.chatManager.loaded_messages_inserted = false
        
        
        //self.navigationController?.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // ---------------------------------- JSQMessageViewController Functions --------------------------------//
    
    
    /**
     * Returns the number of messages in UICollectionView (messages)
     */
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mainViewController.chatManager.messages.count;
    }
    
    
    /**
     *  Setups the Date Label every such messages
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        
        let current =  self.mainViewController.chatManager.messages[indexPath.item].senderId
        var  prev = "NULL"
        
        if(indexPath.item > 0 ){
            prev =  self.mainViewController.chatManager.messages[indexPath.item - 1].senderId
        }
        
        if (current != prev) {
            _ =  self.mainViewController.chatManager.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for:  self.mainViewController.chatManager.messages[indexPath.item].date)
        }
        
        return nil
    }
    
    /**
     *  Returns the bottom height for each message bubble cell
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat{
        
        return 3
        
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message =  self.mainViewController.chatManager.messages[indexPath.item];
        
        
        if(message.isMediaMessage){
            let mediaItem =  message.media
            if mediaItem is JSQPhotoMediaItem{
                let photoItem = mediaItem as! JSQPhotoMediaItem
                let image:UIImage = photoItem.image //UIImage obtained.
                self.selected_image = image
                self.performSegue(withIdentifier: "chatDetailViewController", sender: nil)
            }

            
        }

    }
    
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "chatDetailViewController"){
            let destinationVC = segue.destination as! ChatViewDetailController
            destinationVC.image = self.selected_image
            
            if(self.selected_image == nil){
                print("Image Not Found")
            }
            else{
                print("Image EXISTS!")
            }
            
        }
        
        
    }
    
    

    
    /**
     * Returns the top height for each cell
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        let current =  self.mainViewController.chatManager.messages[indexPath.item].senderId
        var  prev = "NULL"
        
        if(indexPath.item > 0 ){
            prev =  self.mainViewController.chatManager.messages[indexPath.item - 1].senderId
        }
        
        if (current != prev) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault + 5
        }
        
        return 2
    }
    
    /**
     *  Setups each message bubble top height
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let message =  self.mainViewController.chatManager.messages[indexPath.item];
        
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
        
        let message =  self.mainViewController.chatManager.messages[indexPath.item]
        
        
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
        
        let message =  self.mainViewController.chatManager.messages[indexPath.item];
        
        
        if(!message.isMediaMessage){
            if (message.senderId == self.senderId) {
                cell.textView.textColor = UIColor.white
                cell.textView.font = UIFont(name: "Source Sans Pro", size: 17)
            } else {
                cell.textView.textColor = UIColor.black
                cell.textView.font = UIFont(name: "Source Sans Pro", size: 17)
            }
        }
 
 
        return cell;
    }
    
    /**
     *  Setups the message bubble color and cell setup
     */
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        let message =  self.mainViewController.chatManager.messages[indexPath.item];
        
        
        
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
        
        let message =  self.mainViewController.chatManager.messages[indexPath.item];
        
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
        return  self.mainViewController.chatManager.messages[indexPath.item]
    }
    
    
    /**
     *  EventHandler every time user attempts to send message
     */
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        // Play Sent Sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // Append new message in message queue
        self.mainViewController.chatManager.messages.append(JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: date , text: text))
        
        // Save to CoreDatata
        let nil_data = Data()
        self.mainViewController.chatManager.save(senderId: self.senderId ,senderDisplayName: self.senderDisplayName,content: text, date: date, createdAt: -1 , messageSent: true, img: nil_data, isMedia: false)
        
        // Send Message Through Sendbird
        self.mainViewController.chatManager.current_channel.sendUserMessage(text) { (userMessage, error) in
            print("Messege Sent")
        }
        
        // Update UICollectionView and Dismiss TextView
        DispatchQueue.main.async {
            self.finishSendingMessage(animated: true)
        }
        
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please select media", preferredStyle: .actionSheet);
        
        alert.view.tintColor = UIColor.init(red: 6.0/255.0, green: 190.0/255.0, blue: 189.0/255.0, alpha: 1)
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        
    
        let photos = UIAlertAction(title: "From Library", style: .default,    handler: { (alert: UIAlertAction) in
            self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.chooseMedia()
        })
        
        let camera = UIAlertAction(title: "Camera", style: .default,    handler: { (alert: UIAlertAction) in
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.chooseMedia()
        })
        
        alert.addAction(photos);
        alert.addAction(camera);
        alert.addAction(cancel);
        present(alert, animated: true, completion: nil);
        
    }
    
    // END SENDING BUTTONS FUNCTIONS
    
    // PICKER VIEW FUNCTIONS
    
    private func chooseMedia() {
        
        present(picker, animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let compressed_pic = pic.jpeg(.lowest)
            
            //let binary_pic =  UIImagePNGRepresentation(compressed_pic)
            
            let image_ready = UIImage(data: compressed_pic!)
            
            
            let img = JSQPhotoMediaItem(image: image_ready)
        
            let date = Date()
        
            
            // Update UICollectionView and Dismiss TextView
            DispatchQueue.main.async {
                
                self.mainViewController.chatManager.messages.append( JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: date, media: img))
                
                self.mainViewController.chatManager.save(senderId: self.senderId , senderDisplayName: self.senderDisplayName, content: "", date: date, createdAt: -1, messageSent: true , img: compressed_pic!, isMedia: true)
                
                self.finishSendingMessage(animated: true)
            }

            
            
            self.mainViewController.chatManager.current_channel.sendFileMessage(withBinaryData: compressed_pic! , filename: "Recived Image", type: "jpg", size: UInt((compressed_pic?.count)!), data: nil  , completionHandler: { (fileMessage, error) in
                if error != nil {
                    NSLog("Error: %@", error!)
                   

                    return
                }
                
           
             
            })
 
            
        }
        self.dismiss(animated: true, completion: nil);
        
      
    }
    // ---------------------------------------------- Helper Functions --------------------------------------//
    
    
    override func textViewDidChange(_ textView: UITextView) {
        
        if(self.mainViewController.chatManager.connection_established){
            super.textViewDidChange(textView)
        }
        
        // If the text is not empty, the user is typing
        
        if( self.mainViewController.chatManager.connection_established){
            if(textView.text != "" ){
                self.mainViewController.chatManager.current_channel.startTyping()
            }
            else{
                self.mainViewController.chatManager.current_channel.endTyping()
            }
        }
    }
    
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        
        if( self.mainViewController.chatManager.connection_established){
            self.mainViewController.chatManager.current_channel.endTyping()
        }
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
            
            self.mainViewController.chatManager.messages.removeAll()
            self.finishReceivingMessage()
        }
        
    }
    
    
    
    
    func showActivityView(){
        DispatchQueue.main.async {
            self.activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            let connectingLabel = UILabel.init(frame: CGRect(x: 30, y: 0, width: 100, height: 22))
            connectingLabel.text = "Connecting..."
            connectingLabel.font =  UIFont(name: "Source Sans Pro", size: 16)
            connectingLabel.textColor = UIColor.white
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
    
    
    
    func loadStoredMessagesIntoUICollectionView(){
        
        var createdAtDates = [Int64]()
        
        for msg in self.mainViewController.chatManager.stored_messages {
            
            let isMedia = msg.value(forKey: "isMedia") as! Bool
            
            if(!isMedia){
            
                self.mainViewController.chatManager.messages.append(JSQMessage(senderId: String(describing: msg.value(forKey: "senderId")!), senderDisplayName: String(describing: msg.value(forKey: "senderDisplayName")!) , date:( msg.value(forKey: "date")! as! Date) , text: String(describing: msg.value(forKey: "content")!)));
            }
            
            else{
                

                let pic = UIImage(data:msg.value(forKey: "img")! as! Data)
                
                let img = JSQPhotoMediaItem(image: pic)
                
                let senderID = String(describing: msg.value(forKey: "senderId")!)
                
                
                if senderID == self.senderId {
                    img?.appliesMediaViewMaskAsOutgoing = true;
                } else {
                    img?.appliesMediaViewMaskAsOutgoing = false;
                }

                
                
                 self.mainViewController.chatManager.messages.append(JSQMessage(senderId: String(describing: msg.value(forKey: "senderId")!), senderDisplayName: String(describing: msg.value(forKey: "senderDisplayName")!) , date:( msg.value(forKey: "date")! as! Date), media: img))
                
                
            }
            
            
            let current_date = msg.value(forKey: "createdAt") as! Int64
            let sender = String(describing: msg.value(forKey: "senderId")!)
            
            if(sender != self.senderId){
                createdAtDates.append(current_date)
            }
                
        
            
        }
        
        
        
        if(createdAtDates.count > 0){
            self.mainViewController.chatManager.last_message_received = createdAtDates[createdAtDates.count - 1]
        }
        else{
            self.mainViewController.chatManager.last_message_received = 0
        }
        
        // Connect To SendBird Server
        self.mainViewController.chatManager.loaded_messages = true
        self.mainViewController.chatManager.loaded_messages_inserted = true
        
        
        DispatchQueue.main.async {
            self.finishReceivingMessage()
        }
        
    }
    
    
    
    func recievedMessage(){
        DispatchQueue.main.async {
            self.finishReceivingMessage()
        }
    }
    
    
    func showTyping(){
        
        DispatchQueue.main.async {
            self.showTypingIndicator = true
            self.scrollToBottom(animated: true)
            self.collectionView.reloadData()
            
        }
        
    }
    
    func hideTyping(){
        DispatchQueue.main.async {
            self.showTypingIndicator = false
            self.scrollToBottom(animated: true)
            self.collectionView.reloadData()
            
        }
        
    }
    
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
}
}


