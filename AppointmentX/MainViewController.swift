//
//  MainViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 3/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import CoreData
import Firebase


class MainViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl!
 
    // Client Data Variables
    var current_client = Client()
    
    // Project Progress
    @IBOutlet weak var progressImageView: UIImageView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    // Upcoming Appointment
    @IBOutlet weak var appointmentView: UIView!
    
    @IBOutlet weak var appointmentLabel: UILabel!
    
    // FireBase Root Reference
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Receieved Client Data Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUIToReflectClientCase), name: Notification.Name("ROOT"), object: nil)
        
        
        self.sideMenuViewController?.hideMenuViewController()
        
        // Setup Basic UI Elements
        self.addLogoToNavigationBar()
        self.setupMessageBarButton()
        self.setupRefreshControl()
        
        self.appointmentView.layer.borderWidth = 1
        self.appointmentView.layer.borderColor =  UIColor(red:215/255.0, green:214/255.0, blue:217/255.0, alpha: 0.5).cgColor

        
        
        
        // Segue Notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showInbox), name: Notification.Name("chatViewController"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.logOut), name: Notification.Name("logOut"), object: nil)
        
   
        
        
        // Do any additional setup after loading the view.
    }


    func logOut(){
       self.refreshClientDataCoreData()
       self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    func refreshClientDataCoreData(){
        
        DispatchQueue.main.async {
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            // Create Fetch Request
            
            if #available(iOS 10.0, *) {
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClientAuth")
                
                // Create Batch Delete Request
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try managedContext.execute(batchDeleteRequest)
                    
                } catch {
                    // Error Handling
                }
                
            } else {
                let managedContext = appDelegate.managedObjectContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClientAuth")
                
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
    
    
    func updateUIToReflectClientCase(notification: NSNotification){
       self.current_client =  notification.object as! Client
       print("MainViewController: " + self.current_client.name + " succesfully logged in!\n")
      
       
        // Real-time Case Tracking and UI-Update
        
        let conditionRef = rootRef.child("Cases").child(self.current_client.myCase.caseID)
        conditionRef.observe(.value, with: { (snapshot) in
            
            // Get Data From Server
            let caseData = snapshot.value as? NSDictionary
            
      
            self.current_client.myCase.appName = caseData!["appName"] as! String
            self.current_client.myCase.appDescription = caseData!["appDescription"] as! String
            self.current_client.myCase.appFeatures  = caseData!["appFeatures"] as! String
            self.current_client.myCase.platform = caseData!["platform"] as! String
            self.current_client.myCase.caseStatus = caseData!["caseStatus"] as! String
            self.current_client.myCase.deadline = caseData!["deadline"] as! String
            self.current_client.myCase.track = caseData!["track"] as! String
            self.current_client.myCase.start = caseData!["start"] as! String
            self.current_client.myCase.end = caseData!["end"] as! String
            
            // BETA: ADD TRACK AND START TO CASE MODEL
            let track =   self.current_client.myCase.track
            let start =   self.current_client.myCase.start
            let end =   self.current_client.myCase.end
            
            // SET TRACK/DAYS LEFT
            
            self.statusLabel.text = track
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "yyyy/MM/dd"
               let today = Date()
            
            if(start != "N/A"){
                let start_date = dateFormatter.date(from: start)
                self.startLabel.text = String(self.calicuateDaysBetweenTwoDates(start: start_date!, end: today) - 1) + " Days"

            }
            else{
                self.startLabel.text = "N/A Days"
            }
            
            if( end != "N/A"){
                let end_date = dateFormatter.date(from: end)
                self.endLabel.text = String(self.calicuateDaysBetweenTwoDates(start: today, end: end_date!)  + 1) + " Days"
            }
            else{
                self.endLabel.text = "N/A Days"
            }
            
            
            // Set PROGET PROGRESS
            
            if(self.current_client.myCase.caseStatus == "Pending Review"){
                self.progressImageView.image = UIImage(named: "progress-review")
            }
            else if(self.current_client.myCase.caseStatus == "Development"){
                self.progressImageView.image = UIImage(named:"progress-develop")
            }
            else{
                self.progressImageView.image = UIImage(named:"progress-publish")
            }
    
            
       
            
        })
     
        
        // Upcoming Appointment UI Update
        
        let apptRef = rootRef.child("Appointments").child(self.current_client.myCase.scheduler.myAppointment.appointmentID)
        apptRef.observe(.value, with: { (snapshot) in
            
            let data = snapshot.value as? NSDictionary
            
            if(data == nil){
                self.appointmentLabel.text = "No appointment scheduled soon."
            }
            else{
            
                // Update Appoitnment Object
                self.current_client.myCase.scheduler.myAppointment.date = data!["date"] as! String
                self.current_client.myCase.scheduler.myAppointment.time = data!["time"] as! String
                self.current_client.myCase.scheduler.myAppointment.info = data!["info"] as! String
                self.current_client.myCase.scheduler.myAppointment.slot = data!["slot"] as! String
                self.current_client.myCase.scheduler.myAppointment.caseID = data!["caseID"] as! String
                self.current_client.myCase.scheduler.myAppointment.clientID = data!["clientID"] as! String
                self.current_client.myCase.scheduler.myAppointment.appointmentExists = true
                
                self.appointmentLabel.text = self.current_client.myCase.scheduler.myAppointment.info + " meeting at " + self.current_client.myCase.scheduler.myAppointment.date + " at " + self.current_client.myCase.scheduler.myAppointment.time
            }

            
            
        })

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
     func calicuateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }

    func setupMessageBarButton(){
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "inbox_icon_bar"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(MainViewController.showInbox), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(item1, animated: true)
    }
    
    func setupRefreshControl(){

        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.tintColor = UIColor.clear
        self.refreshControl.addTarget(self, action: #selector(MainViewController.updateModelData), for: UIControlEvents.valueChanged)
        self.scrollView.addSubview(self.refreshControl)
        
        self.scrollView.delegate = self

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
