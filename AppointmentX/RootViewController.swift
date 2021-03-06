//
//  RootViewController.swift
//  AKSideMenuStoryboard
//
//  Created by Diogo Autilio on 6/9/16.
//  Copyright © 2016 AnyKey Entertainment. All rights reserved.
//

import UIKit
import AKSideMenu

public class RootViewController: AKSideMenu, AKSideMenuDelegate {

    
    // Client Object Data
    var current_client = Client()
    
    
    override public func awakeFromNib() {
        
        super.awakeFromNib()
        
        
        
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.lightContent
        self.contentViewShadowColor = UIColor.black
        self.contentViewShadowOffset = CGSize(width: 0, height: 0)
        self.contentViewShadowOpacity = 0.8
        self.contentViewShadowRadius = 20
        self.contentViewShadowEnabled = true
        

       
        
        self.contentViewController = self.storyboard!.instantiateViewController(withIdentifier: "contentViewController")
        
        
        
        self.leftMenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "leftMenuViewController")
        self.rightMenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "rightMenuViewController")
        
        
        self.backgroundImage = UIImage.init(named: "background_menu")
        self.delegate = self
        self.panGestureLeftEnabled = true
        self.panGestureRightEnabled = false
      
        self.panFromEdgeZoneWidth = 150
        
       
        
        
    }

    override public func viewDidLoad() {
       
        super.viewDidLoad()
        
        
       
        
    }

    
    
    
    override public func didReceiveMemoryWarning() {
        
        
        super.didReceiveMemoryWarning()
    }

    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        
            return .lightContent
        
    }
    
    
    // MARK: - <AKSideMenuDelegate>

    public func sideMenu(_ sideMenu: AKSideMenu, willShowMenuViewController menuViewController: UIViewController) {
       
        print("willShowMenuViewController")
    }

    public func sideMenu(_ sideMenu: AKSideMenu, didShowMenuViewController menuViewController: UIViewController) {
        

        print("didShowMenuViewController")
    }

    public func sideMenu(_ sideMenu: AKSideMenu, willHideMenuViewController menuViewController: UIViewController) {
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ROOT"), object:self.current_client);
        print("willHideMenuViewController")
    }

    public func sideMenu(_ sideMenu: AKSideMenu, didHideMenuViewController menuViewController: UIViewController) {
    
        print("didHideMenuViewController")
    }
    
    

 
    
}
