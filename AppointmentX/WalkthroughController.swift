//
//  WalkthroughController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 2/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import SwiftGifOrigin


class WalkthroughController: UIViewController, CAAnimationDelegate{
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewAnim: UIImageView!
    @IBOutlet weak var subHeaderLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var iOS_boxButton: UIButton!
    @IBOutlet weak var iOS_Button: UIButton!
    @IBOutlet weak var driod_boxButton: UIButton!
    @IBOutlet weak var driod_Button: UIButton!
    @IBOutlet weak var feature0_boxButton: UIButton!
    @IBOutlet weak var feature0_Button: UIButton!
    @IBOutlet weak var feature1_boxButton: UIButton!
    @IBOutlet weak var feature1_Button: UIButton!
    @IBOutlet weak var feature2_boxButton: UIButton!
    @IBOutlet weak var feature2_Button: UIButton!
    @IBOutlet weak var feature3_boxButton: UIButton!
    @IBOutlet weak var feature3_Button: UIButton!
    @IBOutlet weak var deadline0_boxButton: UIButton!
    @IBOutlet weak var deadline0_Button: UIButton!
    @IBOutlet weak var deadline1_boxButton: UIButton!
    @IBOutlet weak var deadline1_Button: UIButton!
    @IBOutlet weak var deadline2_boxButton: UIButton!
    @IBOutlet weak var deadline2_Button: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    
    // Client Manager Status Fields/Notications
    var current_client:Client!
    let CREATE_CASE = "CREATE_CASE"
    
    
    // Tracking Variables
    var currentPage = 0
    var platform_selection = "N/A"
    var feature0_selection = "N/A"
    var feature1_selection = "N/A"
    var feature2_selection = "N/A"
    var feature3_selection = "N/A"
    var deadline_selection = "N/A"
    
    
    override func viewDidLoad() {
        
        self.imageView.alpha = 0
        self.imageView.alpha = 0
        self.headerLabel.alpha = 0
        self.subHeaderLabel.alpha = 0
        self.bodyLabel.alpha = 0
        self.iOS_Button.alpha = 0
        self.iOS_boxButton.alpha = 0
        self.driod_boxButton.alpha = 0
        self.driod_Button.alpha = 0
        self.feature0_Button.alpha = 0
        self.feature0_boxButton.alpha = 0
        self.feature1_Button.alpha = 0
        self.feature1_boxButton.alpha = 0
        self.feature2_Button.alpha = 0
        self.feature2_boxButton.alpha = 0
        self.feature3_Button.alpha = 0
        self.feature3_boxButton.alpha = 0
        self.deadline0_Button.alpha = 0
        self.deadline0_boxButton.alpha = 0
        self.deadline1_Button.alpha = 0
        self.deadline1_boxButton.alpha = 0
        self.deadline2_Button.alpha = 0
        self.deadline2_boxButton.alpha = 0
        
        
        
        self.imageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.imageViewAnim.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.headerLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.subHeaderLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.bodyLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        self.iOS_boxButton.addTarget(self, action: #selector(WalkthroughController.platformSelected(_:)), for: .touchUpInside)
        self.iOS_Button.addTarget(self, action: #selector(WalkthroughController.platformSelected(_:)), for: .touchUpInside)
        self.driod_boxButton.addTarget(self, action: #selector(WalkthroughController.platformSelected(_:)), for: .touchUpInside)
        self.driod_Button.addTarget(self, action: #selector(WalkthroughController.platformSelected(_:)), for: .touchUpInside)
        
        self.feature0_Button.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        self.feature0_boxButton.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        self.feature1_Button.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        self.feature1_boxButton.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        self.feature2_Button.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        self.feature2_boxButton.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        self.feature3_Button.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        self.feature3_boxButton.addTarget(self, action: #selector(WalkthroughController.featureSelected(_:)), for: .touchUpInside)
        
        self.deadline0_boxButton.addTarget(self, action: #selector(WalkthroughController.deadlineSelected(_:)), for: .touchUpInside)
        self.deadline0_Button.addTarget(self, action: #selector(WalkthroughController.deadlineSelected(_:)), for: .touchUpInside)
        self.deadline1_boxButton.addTarget(self, action: #selector(WalkthroughController.deadlineSelected(_:)), for: .touchUpInside)
        self.deadline1_Button.addTarget(self, action: #selector(WalkthroughController.deadlineSelected(_:)), for: .touchUpInside)
        self.deadline2_boxButton.addTarget(self, action: #selector(WalkthroughController.deadlineSelected(_:)), for: .touchUpInside)
        self.deadline2_Button.addTarget(self, action: #selector(WalkthroughController.deadlineSelected(_:)), for: .touchUpInside)
        
        
        // Disbale Next Button
        nextButton.alpha = 0.3
        nextButton.isEnabled = false
        
        
        // Case File Notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleCaseManagerNotification), name: Notification.Name(self.CREATE_CASE), object: nil)
        
        
        
    }
    
    
    func handleCaseManagerNotification() {
        
        self.performSegue(withIdentifier: "backend-beta", sender: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        self.showNextPhase()
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func nextPhaseClicked(_ sender: Any) {
        
        self.hideCurrentPhase()
    
        
    }
    
    
    func hideCurrentPhase(){
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.imageView.alpha = 0
            self.imageView.alpha = 0
            self.headerLabel.alpha = 0
            self.subHeaderLabel.alpha = 0
            self.bodyLabel.alpha = 0
            self.iOS_Button.alpha = 0
            self.iOS_boxButton.alpha = 0
            self.driod_boxButton.alpha = 0
            self.driod_Button.alpha = 0
            self.feature0_Button.alpha = 0
            self.feature0_boxButton.alpha = 0
            self.feature1_Button.alpha = 0
            self.feature1_boxButton.alpha = 0
            self.feature2_Button.alpha = 0
            self.feature2_boxButton.alpha = 0
            self.feature3_Button.alpha = 0
            self.feature3_boxButton.alpha = 0
            self.deadline0_Button.alpha = 0
            self.deadline0_boxButton.alpha = 0
            self.deadline1_Button.alpha = 0
            self.deadline1_boxButton.alpha = 0
            self.deadline2_Button.alpha = 0
            self.deadline2_boxButton.alpha = 0
            
            
            self.imageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.imageViewAnim.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.headerLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.subHeaderLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.bodyLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            
            
            
        }) { (Bool) in
            
            if(self.currentPage == 3){
                
                self.createNewCaseForClient()
                
            }
            else{
                self.currentPage = self.currentPage + 1
                self.showNextPhase()
            }
            
            
        }
        
        
    }
    
    
    // Handle Cycle Walthrough
    
    func showNextPhase(){
        
        var initialPhase = false
        
        if(currentPage == 0){
            initialPhase = true
        }
        
        
        // Disbale Next Button
        nextButton.alpha = 0.3
        nextButton.isEnabled = false
        

        // Update UI according to UI
        
        switch self.currentPage {
        case 0:
            self.imageView.image = UIImage.init(named: "bulb_front")
            self.imageViewAnim.image = UIImage.init(named: "bulb_bk")
            self.headerLabel.text = "About Your Project"
            self.subHeaderLabel.text = "Help us more by telling us about your project so that we can better assist you."
            self.bodyLabel.text = ""
            initialPhase = true
        
        case 1:
            self.imageView.image = UIImage.init(named: "platform_front")
            self.imageViewAnim.image = UIImage.init(named: "platform_bk")
            self.headerLabel.text = "Platform"
            self.bodyLabel.text = "What platforms would you like to support?"
            self.subHeaderLabel.text = ""
            
            
            UIView.animate(withDuration: 0.4, delay: 1.6, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.iOS_Button.alpha = 1
                self.iOS_boxButton.alpha = 1
                self.driod_Button.alpha = 1
                self.driod_boxButton.alpha = 1
                
            }, completion: { (Bool) in
                self.nextButton.alpha = 1
                self.nextButton.isEnabled = true
            })
            
            
            
        case 2:
            self.imageView.image = UIImage.init(named: "features_front")
            self.imageViewAnim.image = UIImage.init(named: "features_bk")
            self.headerLabel.text = "Features"
            self.bodyLabel.text = "What features would you like to support?"
            self.subHeaderLabel.text = ""
            
            UIView.animate(withDuration: 0.4, delay: 1.6, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.feature0_Button.alpha = 1
                self.feature0_boxButton.alpha = 1
                self.feature1_Button.alpha = 1
                self.feature1_boxButton.alpha = 1
                self.feature2_Button.alpha = 1
                self.feature2_boxButton.alpha = 1
                self.feature3_Button.alpha = 1
                self.feature3_boxButton.alpha = 1
                
            }, completion: { (Bool) in
                self.nextButton.alpha = 1
                self.nextButton.isEnabled = true
            })
            
            
        case 3:
            self.imageView.image = UIImage.init(named: "deadline_front")
            self.imageViewAnim.image = UIImage.init(named: "deadline_bk")
            self.headerLabel.text = "Launch"
            self.bodyLabel.text = "When do you wish to go live?"
            self.subHeaderLabel.text = ""
            
            UIView.animate(withDuration: 0.4, delay: 1.6, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.deadline0_Button.alpha = 1
                self.deadline0_boxButton.alpha = 1
                self.deadline1_Button.alpha = 1
                self.deadline1_boxButton.alpha = 1
                self.deadline2_Button.alpha = 1
                self.deadline2_boxButton.alpha = 1
                
            }, completion: { (Bool) in
                self.nextButton.alpha = 1
                self.nextButton.isEnabled = true
            })
            
            
            
        default:
            self.imageView.image = UIImage.init(named: "bulb_front")
            self.imageViewAnim.image = UIImage.init(named: "bulb_bk")
        }
        
        
        
        self.pageControl.currentPage = self.currentPage
        
        
        
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageView.alpha = 1
            self.imageViewAnim.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageViewAnim.alpha = 0.18
        }, completion: { (Bool) in
            
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.headerLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.headerLabel.alpha = 1
            }, completion: { (Bool) in
                
                UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.subHeaderLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.subHeaderLabel.alpha = 1
                    self.bodyLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.bodyLabel.alpha = 1
                    
                }, completion: { (Bool) in
                    if(initialPhase){
                        self.nextButton.alpha = 1
                        self.nextButton.isEnabled = true
                    }
                })
            })
        })
        
    }
    
    
    
    func platformSelected(_ sender: AnyObject?){
        
        
        switch sender!.tag {
        case 0:
            self.iOS_boxButton.setBackgroundImage(UIImage.init(named:"check_box_1"), for: .normal)
            self.iOS_boxButton.tag = 10
            self.iOS_Button.tag = 10
            
            if(self.platform_selection.lowercased().range(of:"Andriod") == nil){
                self.platform_selection = "iOS"
            }
            else{
                self.platform_selection = "iOS, Andriod"
            }
            
        case 1:
            self.driod_boxButton.setBackgroundImage(UIImage.init(named:"check_box_1"), for: .normal)
            self.driod_boxButton.tag = 11
            self.driod_Button.tag = 11
            
            if(self.platform_selection.lowercased().range(of:"iOS") == nil){
                self.platform_selection = "Andriod"
            }
            else{
                self.platform_selection = "iOS, Andriod"
            }
        case 10:
            self.iOS_boxButton.setBackgroundImage(UIImage.init(named:"check_box_0"), for: .normal)
            self.iOS_boxButton.tag = 0
            self.iOS_Button.tag = 0
            
            if(self.platform_selection.lowercased().range(of:"Andriod") == nil){
                self.platform_selection = "N/A"
            }
            else{
                self.platform_selection = "Andriod"
            }
        case 11:
            self.driod_boxButton.setBackgroundImage(UIImage.init(named:"check_box_0"), for: .normal)
            self.driod_boxButton.tag = 1
            self.driod_Button.tag = 1
            
            if(self.platform_selection.lowercased().range(of:"iOS") == nil){
                self.platform_selection = "N/A"
            }
            else{
                self.platform_selection = "iOS"
            }
            
        default:
            break
        }
        
        
    }
    
    func featureSelected(_ sender: AnyObject?){
        
        
        switch sender!.tag {
        case 0:
            self.feature0_boxButton.setBackgroundImage(UIImage.init(named:"check_box_1"), for: .normal)
            self.feature0_Button.tag = 10
            self.feature0_boxButton.tag = 10
            self.feature0_selection = "Data Hosting/Storage"
        case 1:
            self.feature1_boxButton.setBackgroundImage(UIImage.init(named:"check_box_1"), for: .normal)
            self.feature1_Button.tag = 11
            self.feature1_boxButton.tag = 11
            self.feature1_selection = "Chat Messenging"
            
        case 2:
            self.feature2_boxButton.setBackgroundImage(UIImage.init(named:"check_box_1"), for: .normal)
            self.feature2_Button.tag = 22
            self.feature2_boxButton.tag = 22
            self.feature2_selection = "KNET"
        case 3:
            self.feature3_boxButton.setBackgroundImage(UIImage.init(named:"check_box_1"), for: .normal)
            self.feature3_Button.tag = 33
            self.feature3_boxButton.tag = 33
            self.feature3_selection = "Other"
        case 10:
            self.feature0_boxButton.setBackgroundImage(UIImage.init(named:"check_box_0"), for: .normal)
            self.feature0_Button.tag = 0
            self.feature0_boxButton.tag = 0
            self.feature0_selection = "N/A"
        case 11 :
            self.feature1_boxButton.setBackgroundImage(UIImage.init(named:"check_box_0"), for: .normal)
            self.feature1_Button.tag = 1
            self.feature1_boxButton.tag = 1
            self.feature1_selection = "N/A"
        case 22:
            self.feature2_boxButton.setBackgroundImage(UIImage.init(named:"check_box_0"), for: .normal)
            self.feature2_Button.tag = 2
            self.feature2_boxButton.tag = 2
            self.feature3_selection = "N/A"
        case 33:
            self.feature3_boxButton.setBackgroundImage(UIImage.init(named:"check_box_0"), for: .normal)
            self.feature3_Button.tag = 3
            self.feature3_boxButton.tag = 3
            self.feature3_selection = "N/A"
            
            
        default:
            break
        }
        
        
    }
    
    
    func deadlineSelected(_ sender: AnyObject?){
        
        
        switch sender!.tag {
        case 0:
            self.deadline0_boxButton.setBackgroundImage(UIImage.init(named:"radio_box1"), for: .normal)
            self.deadline1_boxButton.setBackgroundImage(UIImage.init(named:"radio_box0"), for: .normal)
            self.deadline2_boxButton.setBackgroundImage(UIImage.init(named:"radio_box0"), for: .normal)
            self.deadline_selection = "ASAP"
            
        case 1:
            self.deadline0_boxButton.setBackgroundImage(UIImage.init(named:"radio_box0"), for: .normal)
            self.deadline1_boxButton.setBackgroundImage(UIImage.init(named:"radio_box1"), for: .normal)
            self.deadline2_boxButton.setBackgroundImage(UIImage.init(named:"radio_box0"), for: .normal)
            self.deadline_selection = "Very soon"
            
        case 2:
            self.deadline0_boxButton.setBackgroundImage(UIImage.init(named:"radio_box0"), for: .normal)
            self.deadline1_boxButton.setBackgroundImage(UIImage.init(named:"radio_box0"), for: .normal)
            self.deadline2_boxButton.setBackgroundImage(UIImage.init(named:"radio_box1"), for: .normal)
            self.deadline_selection = "Other"
        default:
            break
        }
        
        
    }
    
    
    @IBAction func SkipWalkthrough(_ sender: Any) {
       self.currentPage = 3
       self.hideCurrentPhase()
    }
    
    
    
    
    func createNewCaseForClient(){
        
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.pageControl.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.pageControl.alpha = 0
            self.nextButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.nextButton.alpha = 0
            self.skipButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.skipButton.alpha = 0
            
        }, completion: { (Bool) in
            var features = ""
            
            if(self.feature0_selection == "N/A" && self.feature1_selection == "N/A" && self.feature2_selection == "N/A" && self.feature3_selection == "N/A"){
                features = "N/A"
            }
            else{
                
                
                if(self.feature0_selection != "N/A"){
                    features += self.feature0_selection
                }
                if(self.feature1_selection != "N/A"){
                    features += ", " + self.feature1_selection
                }
                if(self.feature2_selection != "N/A"){
                    features += ", " + self.feature2_selection
                }
                if(self.feature3_selection != "N/A"){
                    features += self.feature3_selection
                }
                
                
            }
            
            self.current_client.myCase.createCase(caseStatus: "Pending Review", platform: self.platform_selection, appName: "N/A", appDescription: "N/A", appFeatures: features, deadline: self.deadline_selection, clientID: (self.current_client?.clientID)!)
        })

        
    }
    
    
    
}

