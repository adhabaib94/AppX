//
//  SignInViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 3/5/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController,  UITextFieldDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var ringImageView: UIImageView!
    
    
    //Loading Indicator
    var loading = UIImage.gif(name: "ring-indicator")
    
    // Client Manager Status Fields/Notications
    let CLIENT_AUTH = "AUTH_COMPLETE"
    let CLIENT_AUTH_FAILED = "AUTH_FAILED"
    var current_client: Client = Client()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Insure View Hidden
        self.scrollView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.scrollView.alpha = 0
        
        // Setup TextField Delegation
        
        self.emailTextField.delegate = self
        self.passTextField.delegate = self
        
        // Keyboard Dismismal On Touch
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        // Client Manager Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.signedInNotification), name: Notification.Name(self.CLIENT_AUTH), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.signedInNotification), name: Notification.Name(self.CLIENT_AUTH_FAILED), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showView()
    }
    
    
    func signedInNotification(notfication: NSNotification){
        
        let notification_type = notfication.name._rawValue as String
        
        print("$SignInViewController: recieved notification -> \(notification_type)")
        
        if(notification_type == self.CLIENT_AUTH){
            self.performSegue(withIdentifier: "chatViewController", sender: nil)
        }
        else if(notification_type == self.CLIENT_AUTH_FAILED){
            self.dismissLoading()
        }
        
        
        
        
    }
    
    // If Account Registeration Fails, Bring back main view
    func dismissLoading(){
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.scrollView.alpha = 1
            self.ringImageView.alpha  = 0
        }, completion: { (Bool) in
            self.shakeTextField(textField: self.emailTextField, errorMsg: "Invalid Email")
            self.shakeTextField(textField: self.passTextField, errorMsg: "")
        })
    }
    
    
    // Insure All Inputs meets basic criteria
    func assertInputsCorrect() -> Bool{
        
        var no_error = true
        
        // Insure All Values Entered
        
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
        
        
        
        return no_error
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
    
    
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        print("$SignInViewController: TEXTFIELD DELEGATE: SHOULD RETURN (\(textField.tag) ")
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
    
    
    
    // Shrink View and Display Loading While Waiting For Account Creation
    func hideView(){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.scrollView.alpha = 0
        }, completion: { (Bool) in
            
            self.dismiss(animated: false, completion: {
                
            })
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissViewController(_ sender: Any) {
        self.hideView()
        
    }
    
    
    @IBAction func signInClicked(_ sender: Any) {
        
        if(self.assertInputsCorrect()){
            self.showLoading()
            self.current_client.authenticateExistingClient(email: self.emailTextField.text!, password: passTextField.text!)
        }
    }
    
    
}
