//
//  MainViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 3/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit



class MainViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl!
 
    // Client Data Variables
    var current_client = Client()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.parseClientData), name: Notification.Name("ROOT"), object: nil)
        
        self.sideMenuViewController?.hideMenuViewController()
        
        // Setup UI Elements
        self.addLogoToNavigationBar()
        self.setupMessageBarButton()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.tintColor = UIColor.clear
        self.refreshControl.addTarget(self, action: #selector(MainViewController.updateModelData), for: UIControlEvents.valueChanged)
        self.scrollView.addSubview(self.refreshControl)
        
        self.scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showInbox), name: Notification.Name("chatViewController"), object: nil)
        
   
        
        
        // Do any additional setup after loading the view.
    }


    func parseClientData(notification: NSNotification){
       self.current_client =  notification.object as! Client
       
        print("MainViewController: " + self.current_client.name + " succesfully logged in!\n")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  

    func setupMessageBarButton(){
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "inbox_icon_bar"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(MainViewController.showInbox), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(item1, animated: true)
    }
    
    func showInbox(){
        self.performSegue(withIdentifier: "chatViewController", sender: nil)
    }
    
    func updateModelData(){
        self.refreshControl.endRefreshing()
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
        imageView.frame(forAlignmentRect:  CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.contentMode = .scaleAspectFit
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0 , width: 44, height: 22))
        titleView.addSubview(imageView)
        
        
        self.navigationItem.titleView = titleView
     
        
    }
    

}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}


/*
extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let screenRect = UIScreen.main.bounds
        return CGSize(width: screenRect.size.width, height: 70)
    }
}
*/
