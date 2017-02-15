//
//  CreateAccountController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 2/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import NVActivityIndicatorView
import Firebase

class CreateAccountController: UIViewController, UITextFieldDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var ringImageView: UIImageView!
    // Client Manager Status Fields/Notications
    let CLIENT_REG = "REG_CLIENT"
    let CLIENT_REG_FAILED = "REG_CLIENT_FAILED"
    let CLIENT_REG_EXISTS = "REG_CLIENT_EXISTS"
    var current_client: Client = Client()
    
    // TextField Management Variable
    var activeField: UITextField?
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Loading Indicator
    var loading = UIImage.gif(name: "ring-indicator")
    
    override func viewDidLoad() {
        
        // Subscribe to Client Notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.registerationNotification), name: Notification.Name(self.CLIENT_REG), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.registerationNotification), name: Notification.Name(self.CLIENT_REG_EXISTS), object: nil)
        
        
        
        // Subscribe to Keyboard Hide/Show Event
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateAccountController.keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateAccountController.keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Setup TextField Delegation
        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passTextField.delegate = self
        self.phoneTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    @IBAction func createAccount(_ sender: UIButton) {
        
        self.current_client.registerNewClient(name: self.nameTextField.text!, email: self.emailTextField.text!, password: self.passTextField.text!, number: self.phoneTextField.text!, legalStatus: "N/A")
        
        self.showLoading()
    }
    
    
    
    func showLoading(){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.scrollView.alpha = 0
        }, completion: { (Bool) in
            
            
        })
        
        self.setupLoading()
    }
    
    func dismissLoading(){
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.scrollView.alpha = 1
            self.ringImageView.alpha  = 0
        })
    }

    

    func setupLoading(){
        
        DispatchQueue.main.async {
            
            self.ringImageView.alpha = 0
            self.ringImageView.loadGif(name: "ring-indicator")
            self.ringImageView.animationImages = self.loading?.images
            
            var values = [CGImage]()
            for image in self.loading!.images! {
                values.append(image.cgImage!)
            }
            
            self.ringImageView.alpha = 0
            
            // Create animation and set SwiftGif values and duration
            let animation = CAKeyframeAnimation(keyPath: "contents")
            animation.calculationMode = kCAAnimationCubic
            animation.duration = self.loading!.duration
            animation.values = values

            // Other stuff
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            // Set the delegate
            animation.delegate = self
            self.ringImageView.layer.add(animation, forKey: "animation")
            
            self.ringImageView.contentMode = .scaleAspectFit
            self.ringImageView.animationDuration = 1
            
            self.ringImageView.startAnimating()
            
            self.ringImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.ringImageView.alpha = 1
                self.ringImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }, completion: { (Bool) in
                
                
            })
            
            
        }
        
    }
    
    
    
    func registerationNotification(notfication: NSNotification){
        
         let notification_type = notfication.name._rawValue as String
         
         print("$CreateAccountController: recieved notification -> \(notification_type)")
         
         if(notification_type == self.CLIENT_REG){
         //   self.performSegue(withIdentifier: "walkthrough", sender: nil)
        // self.hideAcitivityView(message: "Registeration Complete!", segue: true)
         }
         else if(notification_type == self.CLIENT_REG_EXISTS){
        // self.hideAcitivityView(message: "Registeration Failed, Account Already Exists!", segue: false)
            self.dismissLoading()
        }
            
        
        
    }
    
    
    // Show ActivityView
    func showActivityView(message: String){
        
        
        // Create BackLight View
        //let frame_back = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        
        // Create BackLight View
        let frame_back = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        let backlight_view = UIView(frame: frame_back)
        backlight_view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        
        backlight_view.tag = 100
        
        self.view.addSubview(backlight_view)
        
        UIView.animate(withDuration: 0.3, animations: {
            backlight_view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.85)
        })

        
    
        
        // Create Activity View
        let frame = CGRect(x: (self.view.frame.width/2) - 50, y:  (self.view.frame.height/2) - 50, width: 100, height: 100)
        
        let activityView = NVActivityIndicatorView(frame: frame,
                                                   type: NVActivityIndicatorType(rawValue: 26)!, color: UIColor.white)
        
        activityView.tag = 101
        
        
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        // Create Label
        
        let frame_msg = CGRect(x:0, y: 100, width: self.view.frame.width, height: self.view.frame.height)
        let msg_Label = UILabel(frame: frame_msg)
        msg_Label.textColor =  UIColor.init(red: 6/255, green: 190/255, blue: 189/255, alpha: 1)
        msg_Label.text = ""
        msg_Label.textAlignment = NSTextAlignment.center
        msg_Label.tag = 102
        
        self.view.addSubview(msg_Label)
        
    }
    
    // Hide Activity View
    func hideAcitivityView(message: String, segue: Bool){
        
        // Change Label
        let msg_label: UILabel = self.view.viewWithTag(102) as! UILabel
        msg_label.text = ""
        
        // Get Other View's
        let back_light: UIView = self.view.viewWithTag(100)!
        let activityView: NVActivityIndicatorView = self.view.viewWithTag(101) as! NVActivityIndicatorView
        
        
        // Remove Acitivity View After 3 Secs
        let delayInSeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            UIView.animate(withDuration: 0.3, animations: {
                activityView.stopAnimating()
                activityView.removeFromSuperview()
                back_light.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
                msg_label.removeFromSuperview()
            }, completion: { (Bool) in
                
               
                back_light.removeFromSuperview()
                
                if(segue){
                    self.performSegue(withIdentifier: "walkthrough", sender: nil)
                }
                
            })
            
            
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        activeField = textField
        print("$CreateAccountController: TEXTFIELD DELEGATE: DID BEGIN EDIT (\(textField.tag)")
 
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        activeField = nil
        print("$CreateAccountController: TEXTFIELD DELEGATE: SHOULD END EDIT (\(textField.tag)")
        self.view.endEditing(true)
    
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        print("$CreateAccountController: TEXTFIELD DELEGATE: SHOULD RETURN (\(textField.tag) ")
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
     
    }
    
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
       
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
       if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
 
}
