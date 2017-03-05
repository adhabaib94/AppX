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
    
    @IBOutlet weak var greetingLabel: UILabel!
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
        
        
        // Keyboard Dismismal On Touch
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateAccountController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showView()
    }
    

    // Create Account IBACTION
    @IBAction func createAccount(_ sender: UIButton) {
        
        if (self.assertInputsCorrect()){
            self.current_client.registerNewClient(name: self.nameTextField.text!, email: self.emailTextField.text!, password: self.passTextField.text!, number: self.phoneTextField.text!, legalStatus: "N/A")
            
            self.dismissKeyboard()
            self.showLoading()
            
        }
    }
    
    // Shrink View and Display Loading While Waiting For Account Creation
    func showLoading(){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.scrollView.alpha = 0
            self.dismissKeyboard()
        }, completion: { (Bool) in
            
        })
        
        self.setupLoading()
    }
    
    
    // If Account Registeration Fails, Bring back main view
    func dismissLoading(){
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.scrollView.alpha = 1
            self.ringImageView.alpha  = 0
        }, completion: { (Bool) in
            self.shakeTextField(textField: self.emailTextField, errorMsg: "Email Taken")
        })
    }
    
    
    // Shrink View and Display Loading While Waiting For Account Creation
    func hideView(){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.scrollView.alpha = 0
        }, completion: { (Bool) in
            
            self.performSegue(withIdentifier: "signInViewController", sender: nil)
            
        })
        
    }
    
    
    // If Account Registeration Fails, Bring back main view
    func showView(){
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.scrollView.alpha = 1
            self.ringImageView.alpha  = 0
        }, completion: { (Bool) in
          
        })
    }
    
    @IBAction func showSignView(_ sender: Any) {
        
        self.hideView()
    
        
    }
    
    // Insure All Inputs meets basic criteria
    func assertInputsCorrect() -> Bool{
        
        var no_error = true
        
        // Insure All Values Entered
        if(self.nameTextField.text == ""){
            self.shakeTextField(textField: self.nameTextField, errorMsg: "")
            no_error = false
        }
        if(self.emailTextField.text == ""){
            self.shakeTextField(textField: self.emailTextField, errorMsg: "")
            no_error = false
        }
        else  if(emailTextField.text?.lowercased().range(of:"@") == nil || emailTextField.text?.lowercased().range(of:".com") == nil ){
            self.shakeTextField(textField: self.emailTextField, errorMsg: "Invalid Email")
            no_error = false
        }
        if(self.passTextField.text == ""){
            self.shakeTextField(textField: self.passTextField, errorMsg: "")
            no_error = false
        }
        if(self.phoneTextField.text == ""){
            self.shakeTextField(textField: self.phoneTextField, errorMsg: "")
            no_error = false
        }
        else if(phoneTextField.text?.characters.count != 8){
            self.shakeTextField(textField: self.phoneTextField, errorMsg: "Invalid Number")
            no_error = false
        }
        
        
        
        
        return no_error
    }
    
    
    // Setup Loading GIF
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
    
    
    // Shake animation on textfields to showcase errors
    func shakeTextField(textField: UITextField, errorMsg: String){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 10, y: textField.center.y))
        textField.layer.add(animation, forKey: "position")
        textField.text = errorMsg
        
    }
    
    // Handle Client Notififcations
    func registerationNotification(notfication: NSNotification){
        
        let notification_type = notfication.name._rawValue as String
        
        print("$CreateAccountController: recieved notification -> \(notification_type)")
        
        if(notification_type == self.CLIENT_REG){
            
            
            UIView.animate(withDuration: 0.4, animations: {
                self.ringImageView.alpha = 0
                self.ringImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: { (Bool) in
                
                self.performSegue(withIdentifier: "walkthrough", sender: nil)
                
            })
            
            
            
        }
        else if(notification_type == self.CLIENT_REG_EXISTS){
            
            self.dismissLoading()
        }
        
        
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        activeField = textField
        print("$CreateAccountController: TEXTFIELD DELEGATE: DID BEGIN EDIT (\(textField.tag)")
        if(textField.tag == phoneTextField.tag){
            self.addDoneButtonOnKeyboard()
        }
        else{
            self.doneButtonAction()
        }
        
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
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CreateAccountController.doneButtonAction))
        done.tintColor = UIColor.init(red: 6.0/255.0, green: 190.0/255.0, blue: 189.0/255.0, alpha: 1)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.phoneTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.phoneTextField.resignFirstResponder()
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
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    // Segue Data Passing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier != "chatViewController" && segue.identifier != "signInViewController"){
            let destinationVC = segue.destination as! WalkthroughController
            destinationVC.current_client = self.current_client
        }

        
    }
    
    
}
