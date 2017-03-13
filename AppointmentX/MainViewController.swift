//
//  MainViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 3/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        // Setup UI Elements
        self.addLogoToNavigationBar()
      //  self.addCallButtonToNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showInbox), name: Notification.Name("chatViewController"), object: nil)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInbox(){
        self.performSegue(withIdentifier: "chatViewController", sender: nil)
    }
    
    // Setup Status bar to Light Skin
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func showSideBar(_ sender: Any) {
        
        self.sideMenuViewController!.presentLeftMenuViewController()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    
    // Add Logo To MainViewController Navbar
    func addLogoToNavigationBar(){
  
        let logo = UIImage(named: "navbar_logo")
        let imageView = UIImageView(image:logo)
        imageView.frame(forAlignmentRect: CGRect(x: 0 , y: 0, width: 200, height: 30))
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationItem.titleView?.sizeToFit()
        
    }
    
 
    

}

extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let screenRect = UIScreen.main.bounds
        return CGSize(width: screenRect.size.width, height: 70)
    }
}
