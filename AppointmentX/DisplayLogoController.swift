//
//  DisplayLogoController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 2/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//


//
//  ViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 1/30/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//
import Foundation
import UIKit
import SwiftGifOrigin
import SendBirdSDK
import CoreData



class DisplayLogoController: UIViewController, CAAnimationDelegate{
    @IBOutlet weak var imageView: UIImageView!


    var logo = UIImage.gif(name: "logo")
    
    // Core Data Variables
    var skip_sign_in = false
    var client_data: [NSManagedObject] = []
    
    // Client Manager Status Fields/Notications
    let CLIENT_AUTH = "AUTH_COMPLETE"
    let CLIENT_AUTH_FAILED = "AUTH_FAILED"
    let CLIENT_DATA_RETREIVED = "CLIENT_DONE"
    var current_client: Client = Client()
    
    
    override func viewDidLoad() {

        // BETA -> Setup SendBird Authentication
        SBDMain.initWithApplicationId("2D70703C-C856-4001-954F-DCFB88A944CD")
        
        self.fetchClientDataFromCoreData()
        
        // Client Manager Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.signedInNotification), name: Notification.Name(self.CLIENT_AUTH), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.signedInNotification), name: Notification.Name(self.CLIENT_AUTH_FAILED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.signedInNotification), name: Notification.Name(self.CLIENT_DATA_RETREIVED), object: nil)
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.perform(#selector(self.setup), with: nil, afterDelay: 0.5 )
    }
    
    
    func setup(){
        
        DispatchQueue.main.async {
            
            self.imageView.alpha = 0
            self.imageView.loadGif(name: "logo")
            self.imageView.animationImages = self.logo?.images
            
            var values = [CGImage]()
            for image in self.logo!.images! {
                values.append(image.cgImage!)
            }
            
            self.imageView.alpha = 0
            
            // Create animation and set SwiftGif values and duration
            let animation = CAKeyframeAnimation(keyPath: "contents")
            animation.calculationMode = kCAAnimationCubic
            animation.duration = self.logo!.duration
            animation.values = values
            // Set the repeat count
            animation.repeatCount = 1
            // Other stuff
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            // Set the delegate
            animation.delegate = self
            self.imageView.layer.add(animation, forKey: "animation")
            
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.animationRepeatCount = 1
            self.imageView.animationDuration = 3
  
            self.imageView.startAnimating()
            
            self.imageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 1, animations: {
                self.imageView.alpha = 1
                 self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { (Bool) in
                
                
            })
            
            
        }

    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            print("Animation finished")
            self.imageView.image = self.logo?.images?[(self.logo?.images?.count)! - 1]
            self.perform(#selector(self.fadeOut), with: nil, afterDelay: 1)
            
        }
    }
    
    
    func fadeOut()  {
        
        self.spin(options: UIViewAnimationOptions.curveEaseIn, speed: 0.4)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.imageView.alpha = 0
            
        }) { (Bool) in
            
            if(self.client_data.isEmpty || self.client_data.count > 1){
                self.performSegue(withIdentifier: "create-account", sender: nil)
            }
            else{
            
                if(self.skip_sign_in){
                    self.performSegue(withIdentifier: "rootViewController", sender: nil)
                }
              
                
            }
           
            
        }

        
    }

    func spin(options: UIViewAnimationOptions, speed: Double){
        
        UIView.animate(withDuration: speed, delay: 0, options: options, animations: {
            
            let r = atan2f(Float(self.imageView.transform.b), Float(self.imageView.transform.a))
            
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Float(r + 10)))
            
        }) { (Bool) in
                self.spin(options: UIViewAnimationOptions.curveLinear, speed: speed)
            
            
        }
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    
    func fetchClientDataFromCoreData(){
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
                    NSFetchRequest<NSManagedObject>(entityName: "ClientAuth")
                
                //3
                do {
                    self.client_data = try managedContext.fetch(fetchRequest)
                    let email = String(describing: self.client_data[0].value(forKey: "email")!)
                    let pass = String(describing: self.client_data[0].value(forKey: "password")!)
                    
                    self.current_client.authenticateExistingClient(email: email, password: pass)
                    
                    print("$DisplayLogoViewController: Found Client Data " + email  + ", " + pass + "\n")
                    
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClientAuth")
                
                do {
                    let results =
                        try managedContext.fetch(fetchRequest)
                    self.client_data = results as! [NSManagedObject]
                    let email = String(describing: self.client_data[0].value(forKey: "email")!)
                    let pass = String(describing: self.client_data[0].value(forKey: "password")!)
                    
                    self.current_client.authenticateExistingClient(email: email, password: pass)
                    
                    print("$DisplayLogoViewController: Found Client Data " + email  + ", " + pass + "\n")

                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }        }
            
        }
    }
    
    
    func signedInNotification(notfication: NSNotification){
        
        let notification_type = notfication.name._rawValue as String
        
        print("$SignInViewController: recieved notification -> \(notification_type)")
        
        if(notification_type == self.CLIENT_DATA_RETREIVED){
            
            // INSURE FAULT TOLERENT, case must exists before going to mainViewController
            
            if(self.current_client.myCase.caseExists){
                
                self.performSegue(withIdentifier: "rootViewController", sender: nil)
            }
            else{
                self.current_client.myCase.createCase(caseStatus: "Pending Review", platform: "N/A", appName: "N/A", appDescription: "N/A", appFeatures: "N/A", deadline: "N/A", clientID: self.current_client.clientID)
            }
            
        }
        else if(notification_type == self.CLIENT_AUTH_FAILED){
                self.performSegue(withIdentifier: "create-account", sender: nil)
        }
        
        
        
        
    }

    
    
    
    
    // Segue Data Passing
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "rootViewController"){
            let destinationVC = segue.destination as! RootViewController
            destinationVC.current_client = self.current_client
            
        }
        
        
    }

    
}

