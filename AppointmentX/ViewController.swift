//
//  ViewController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 1/30/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView


class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    @IBOutlet weak var day1: UIButton!
    @IBOutlet weak var day2: UIButton!
    @IBOutlet weak var day3: UIButton!
    @IBOutlet weak var slot1: UIButton!
    @IBOutlet weak var slot2: UIButton!
    @IBOutlet weak var slot3: UIButton!
    @IBOutlet weak var slot4: UIButton!
    
    @IBOutlet weak var calender: FSCalendar!

    var inital_auth = true
    
    var daySelection = ""
    var timeSelection = ""
    var slotSelection = ""
    
    var slotButtons = [UIButton]()
    
    
    // Notification Variables
    
    
    // Client Manager Status Fields/Notications
    let CLIENT_REG = "REG_CLIENT"
    let CLIENT_REG_FAILED = "REG_CLIENT_FAILED"
    let CLIENT_REG_EXISTS = "REG_CLIENT_EXISTS"
    
 
    let CLIENT_AUTH = "AUTH_COMPLETE"
    let CLIENT_AUTH_FAILED = "AUTH_FAILED"
    
    
    let CLIENT_UPDATE = "UPD_CLIENT"
    let CLIENT_UPDATE_FAILED = "UPD_CLIENT_FAILED"
    
    let CLIENT_DELETE = "DEL_CLIENT"
    let CLIENT_DELETE_FAILED = "DEL_CLIENT_FAILED"
    
    
    
    let SCH_FETCHED_SLOTS = "SCH_FETCH_COMPLETE"
    let AUTH_NOTIFICATION = "APPT_GET"


    let CREATE_CASE = "CREATE_CASE"
    let UPDATE_CASE = "UPDATE_CASE"
    let DELETE_CASE = "DELETE_CASE"
    let GET_CASE = "GET_CASE"
    
    
    
    let APPT_NOTIFICATION_CREATE = "APPT_CREATED"
    let APPT_NOTIFICATION_UPDATED = "APPT_UPDATED"
    let APPT_NOTIFICATION_DELETED = "APPT_DELETED"
    
    
    var current_client: Client = Client()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calender Delegation
        calender.dataSource = self
        calender.delegate = self
        calender.appearance.eventDefaultColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
       
        
        // Append All Slot Buttons
        self.slotButtons.append(self.slot1)
        self.slotButtons.append(self.slot2)
        self.slotButtons.append(self.slot3)
        self.slotButtons.append(self.slot4)
        
        // Handle Getting Fetched Available Appts
        
        // Client Notification Observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(self.CLIENT_UPDATE), object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(self.CLIENT_DELETE), object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(self.CLIENT_REG), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(self.CLIENT_REG_EXISTS), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(CLIENT_AUTH_FAILED), object: nil)
        
        
        // Scheduler Notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(SCH_FETCHED_SLOTS), object: nil)
    
       // Authentication Notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(AUTH_NOTIFICATION), object: nil)
        
   
        
        // Case File Notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(self.CREATE_CASE), object: nil)
 
         NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(self.UPDATE_CASE), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(self.DELETE_CASE), object: nil)

        // Appointment Nottifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(APPT_NOTIFICATION_CREATE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(APPT_NOTIFICATION_DELETED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleClientManagerNotification), name: Notification.Name(APPT_NOTIFICATION_UPDATED), object: nil)
        
 

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func registerNewClient(_ sender: Any) {
        self.showActivityView(message: "Registering...")
        current_client.registerNewClient(firstName: "Mohammed", lastName: "Abo Zaid", email: "abuzaid95@gmail.com", password: "123xyz", number: "99166300", legalStatus: "Sole Trader")
    }
    
    
    @IBAction func signExistingClient(_ sender: Any) {
        
        self.showActivityView(message: "Signing in...")
        current_client.authenticateExistingClient(email: "abuzaid95@gmail.com", password: "123xyz")
        
      
    }
    
    
    @IBAction func updateExistingClient(_ sender: Any) {
        
        if(current_client.REGISTERATION_STATUS && current_client.AUTHENTICATION_STATUS == 1){
            current_client.firstName = "Mohammed"
            current_client.lastName = "Abu Zaid"
            self.showActivityView(message: "Updating...")
            current_client.updateClientInformation()
        }
        else{
            self.showActivityView(message: "DEBUG: Client Not Logged In")
            self.hideAcitivityView(message: "DEBUG: Client Not Logged In")
            
            print("$ViewController: Client Not Logged In\n")
        }
    }
    
    
    @IBAction func deleteExistingClient(_ sender: Any) {
        if(current_client.REGISTERATION_STATUS && current_client.AUTHENTICATION_STATUS == 1){
            self.showActivityView(message: "Deleting...")
            current_client.deleteClientAccount()
        }
        else{
            self.showActivityView(message: "DEBUG: Client Not Logged In")
            self.hideAcitivityView(message: "DEBUG: Client Not Logged In")

            print("$ViewController: Client Not Logged In\n")
        }
    }
    
    @IBAction func addCaseFileToClient(_ sender: Any) {
        if(current_client.REGISTERATION_STATUS && current_client.AUTHENTICATION_STATUS == 1 && !self.current_client.myCase.caseExists){
            
            self.showActivityView(message: "Adding Case File...")
            
            current_client.myCase.createCase(caseStatus: "Pending Review", platform: "oa", appName: "CakeTown", appDescription: "Food Delivery with a different selection of deserts", appFeatures: "Order, Tracking, Messaging", deadline: "April 1st, 2017", clientID: self.current_client.clientID)
        }
        else{
            
            if(self.current_client.myCase.caseExists){
                self.showActivityView(message: "DEBUG: Case File Already Exists")
                self.hideAcitivityView(message: "DEBUG: Case File Already Exists")
            }
            else{
                self.showActivityView(message: "DEBUG: Client Not Logged In")
                self.hideAcitivityView(message: "DEBUG: Client Not Logged In")
            }
            
           
            print("$ViewController: Client Not Logged In\n")
        }
    }
    
    @IBAction func updateExistingCaseFileToClient(_ sender: Any) {
        if(current_client.myCase.caseExists && current_client.REGISTERATION_STATUS && current_client.AUTHENTICATION_STATUS == 1){
            
            self.showActivityView(message: "Updating Case File...")
            current_client.myCase.appName = "Heavens Bakery"
            current_client.myCase.appDescription = "Pickup the best and only the best deserts in Kuwait"
            current_client.myCase.updateCase()
        }
        else{
            if(!current_client.REGISTERATION_STATUS){
                self.showActivityView(message: "DEBUG: Client Not Logged In")
                self.hideAcitivityView(message: "DEBUG: Client Not Logged In")
            }
            else{
                self.showActivityView(message: "DEBUG: No Case Found To Update")
                self.hideAcitivityView(message: "DEBUG: No Case Found To Update")

            }
 
            print("$ViewController: No Case Found To Update...\n")
        }
    }
    
    
    @IBAction func deleteExistingCaseFileToClient(_ sender: Any) {
        if(current_client.myCase.caseExists && current_client.REGISTERATION_STATUS && current_client.AUTHENTICATION_STATUS == 1){
            self.showActivityView(message: "Deleting Case File...")
            current_client.myCase.deleteCase()
        }
        else{
            if(!current_client.REGISTERATION_STATUS){
                self.showActivityView(message: "DEBUG: Client Not Logged In")
                self.hideAcitivityView(message: "DEBUG: Client Not Logged In")
            }
            else{
                self.showActivityView(message: "DEBUG: No Case Found To Update")
                self.hideAcitivityView(message: "DEBUG: No Case Found To Update")
                
            }
            print("$ViewController: No Case Found To Update...\n")
        }
    }
    
    
    
    @IBAction func bookAppointmentToCaseForClient(_ sender: Any) {
        if(current_client.myCase.caseExists && current_client.REGISTERATION_STATUS && current_client.AUTHENTICATION_STATUS == 1 && self.daySelection != "" && self.timeSelection != "" && !current_client.myCase.scheduler.myAppointment.appointmentExists){
            

            self.showActivityView(message: "Booking Appointment...")
            
            current_client.myCase.scheduler.scheduleAppointment(date: self.daySelection, time: self.timeSelection, slot: self.slotSelection, info: "Consulation")
            
            
            self.current_client.myCase.scheduler.getAvailableAppointmentSlots(day: self.daySelection)
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.calender.setCurrentPage(formatter.date(from: "2015-10-10")!, animated: true)


            
        }
        else{
            
            if(current_client.AUTHENTICATION_STATUS != 1){
                self.showActivityView(message: "DEBUG: Client Not Logged In")
                self.hideAcitivityView(message: "DEBUG: Client Not Logged In")
            }
            
            else if(current_client.myCase.scheduler.myAppointment.appointmentExists){
                self.showActivityView(message: "DEBUG: Appointment Already Exists...")
                self.hideAcitivityView(message: "DEBUG: Appointment Already Exists...")
                print("$ViewController: Appointment Already Exists..\n")
            }
            else if(!current_client.myCase.caseExists){
                self.showActivityView(message: "DEBUG: No Case Found")
                self.hideAcitivityView(message: "DEBUG: No Case Found")
            }
            else{
                self.showActivityView(message: "DEBUG: Missing Time/Day Inputs")
                self.hideAcitivityView(message: "DEBUG: Missing Time/Day Inputs")
                
                
            }
            print("$ViewController: No Case Found To Get Appointment...\n")
            
        }
        
    }
    @IBAction func alterExistingAppointment(_ sender: Any) {
        if(current_client.myCase.scheduler.myAppointment.appointmentExists && (self.daySelection != "" && self.timeSelection != "" && self.slotSelection != "" ) && self.current_client.myCase.scheduler.myAppointment.appointmentExists && self.current_client.myCase.scheduler.myAppointment.time != self.timeSelection){
            self.current_client.myCase.scheduler.myAppointment.date = self.daySelection
            self.current_client.myCase.scheduler.myAppointment.time = self.timeSelection
            self.current_client.myCase.scheduler.myAppointment.slot = self.slotSelection
            self.current_client.myCase.scheduler.alterSchueledAppointment()
            
            self.showActivityView(message: "Altering Appointment...")
            
            self.current_client.myCase.scheduler.getAvailableAppointmentSlots(day: self.daySelection)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.calender.setCurrentPage(formatter.date(from: "2015-10-10")!, animated: true)

            
        }
        else{
            if(current_client.AUTHENTICATION_STATUS != 1){
                self.showActivityView(message: "DEBUG: Client Not Logged In")
                self.hideAcitivityView(message: "DEBUG: Client Not Logged In")
            }
            else if(!current_client.myCase.caseExists){
                self.showActivityView(message: "DEBUG: No Case Found")
                self.hideAcitivityView(message: "DEBUG: No Case Found")
            }
            else if(!current_client.myCase.scheduler.myAppointment.appointmentExists){
                self.showActivityView(message: "DEBUG: No Appointment Found")
                self.hideAcitivityView(message: "DEBUG: No Appointment Found")
            }
            else{
                self.showActivityView(message: "DEBUG: Missing Time/Day Inputs")
                self.hideAcitivityView(message: "DEBUG: Missing Time/Day Inputs")

            }

            print("$ViewController: No Case Found To Get Appointment...\n")
                
        }
        
    }
    
    @IBAction func cancelAppointmentToCaseForClient(_ sender: Any) {
        
        if(current_client.myCase.caseExists && current_client.REGISTERATION_STATUS && current_client.AUTHENTICATION_STATUS == 1 && current_client.myCase.scheduler.myAppointment.appointmentExists){
            
            self.showActivityView(message: "Canceling Appointment...")
            
            current_client.myCase.scheduler.cancelScheduledAppointment()
            
            self.current_client.myCase.scheduler.getAvailableAppointmentSlots(day: self.daySelection)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.calender.setCurrentPage(formatter.date(from: "2015-10-10")!, animated: true)
            
     
        }
        else{
            if(current_client.AUTHENTICATION_STATUS != 1){
                self.showActivityView(message: "DEBUG: Client Not Logged In")
                self.hideAcitivityView(message: "DEBUG: Client Not Logged In")
            }
            else if(!current_client.myCase.caseExists){
                self.showActivityView(message: "DEBUG: No Case Found")
                self.hideAcitivityView(message: "DEBUG: No Case Found")
            }
            else if(!current_client.myCase.scheduler.myAppointment.appointmentExists){
                self.showActivityView(message: "DEBUG: No Appointment Found")
                self.hideAcitivityView(message: "DEBUG: No Appointment Found")
            }
            
            print("$ViewController: No Case Found To Delete Appointment...\n")
        }
        
    }
    

    
    @IBAction func selectSlotOne(_ sender: Any) {
        self.slot1.backgroundColor = UIColor.init(red: 0.76, green: 0.207, blue: 0.188, alpha: 1)
        self.slot2.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot3.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot4.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.timeSelection = (self.slot1.titleLabel?.text)!
        self.slotSelection = "1"
       
        
       
    }
    
    @IBAction func selectSlotTwo(_ sender: Any) {
        self.slot1.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot2.backgroundColor = UIColor.init(red: 0.76, green: 0.207, blue: 0.188, alpha: 1)
        self.slot3.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot4.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.timeSelection = (self.slot2.titleLabel?.text)!
        self.slotSelection = "2"
        
    }
    
    @IBAction func selectSlot3(_ sender: Any) {
        self.slot1.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot2.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot3.backgroundColor = UIColor.init(red: 0.76, green: 0.207, blue: 0.188, alpha: 1)
        self.slot4.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.timeSelection = (self.slot3.titleLabel?.text)!
        self.slotSelection = "3"
     
    }
    
    @IBAction func selectSlotFour(_ sender: Any) {
        self.slot1.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot2.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot3.backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
        self.slot4.backgroundColor = UIColor.init(red: 0.76, green: 0.207, blue: 0.188, alpha: 1)
        self.timeSelection = (self.slot4.titleLabel?.text)!
        self.slotSelection = "4"
      
    }
    
    
    func handleClientManagerNotification(notfication: NSNotification){
        
        let notification_type = notfication.name._rawValue as String
        
        print("$ViewController: recieved notification -> \(notification_type)")
        
      
        
        if(notification_type == self.AUTH_NOTIFICATION){
            self.hideAcitivityView(message: "Welcome Back, \(self.current_client.firstName)!")
            
        }
        else if(notification_type == self.CLIENT_AUTH_FAILED){
            self.hideAcitivityView(message: "No Account Found!")
        }
        else if(notification_type == self.CLIENT_REG){
            self.hideAcitivityView(message: "Registeration Complete!")
        }
        else if(notification_type == self.CLIENT_REG_EXISTS){
            self.hideAcitivityView(message: "Registeration Failed, Account Already Exists!")
        }
        else if(notification_type == self.CREATE_CASE){
            self.hideAcitivityView(message: "Case File Added!")
        }
        else if(notification_type == self.CLIENT_UPDATE || notification_type == self.UPDATE_CASE){
            self.hideAcitivityView(message: "Updated \(self.current_client.firstName) Information!")
        }
        else if(notification_type == self.CLIENT_DELETE || notification_type == self.DELETE_CASE){
            self.hideAcitivityView(message: "Deleted \(self.current_client.firstName) Information!")
        }
            
        else if(notification_type == self.APPT_NOTIFICATION_CREATE){
            self.hideAcitivityView(message: "Booked Appointment!")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.calender.setCurrentPage(formatter.date(from: self.daySelection)!, animated: true)
        }
            
        else if(notification_type == self.APPT_NOTIFICATION_UPDATED){
            self.hideAcitivityView(message: "Altered Appointment!")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.calender.setCurrentPage(formatter.date(from: self.daySelection)!, animated: true)

        }
            
        else if(notification_type == self.APPT_NOTIFICATION_DELETED){
            self.hideAcitivityView(message: "Canceled Appointment!")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.calender.setCurrentPage(formatter.date(from: self.daySelection)!, animated: true)

        }
            
        else if(notification_type == self.SCH_FETCHED_SLOTS){
            self.toggleSlotButtonsUI()
        }
        
        
        
        
    }
    
    
    func toggleSlotButtonsUI(){
        // Handle Toggling Slot Buttons
        
        let availableSlots = self.current_client.myCase.scheduler.availableSlots
        
        var slotIndex = 0
        for slot in availableSlots {
            
            if(slot){
                self.slotButtons[slotIndex].isEnabled = true
                self.slotButtons[slotIndex].alpha = 1
                self.slotButtons[slotIndex].backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 1)
            }
            else{
                self.slotButtons[slotIndex].isEnabled = false
                self.slotButtons[slotIndex].alpha = 0.3
                self.slotButtons[slotIndex].backgroundColor = UIColor.init(red: 0.149, green: 0.478, blue: 0.847, alpha: 0.3)
            }
            
            slotIndex = slotIndex + 1
            
        }
        
    }
    
    
    // Calender Date Selection Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
            
        }
        
        // Select daySelection
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let date_selected = dateformatter.string(from: date)
        self.daySelection = date_selected
        
        // Print Day Selected
        print("$ViewController: Client Selected \(date_selected)\n")
        
        // Get Available Slots
         self.current_client.myCase.scheduler.getAvailableAppointmentSlots(day: self.daySelection)
        
      
    }
    
    // FCCalender Delegate For Bounds
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        let rect = CGRect(
            origin: self.calender.frame.origin,
            size: bounds.size
        )
        self.calender.frame = rect
    }
    
    func calendar(_ calendar: FSCalendar, hasEventFor date: Date) -> Bool {
        
        // Select daySelection
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let date_selected = dateformatter.string(from: date)
 

        if(date_selected == self.current_client.myCase.scheduler.myAppointment.date){
            return true
        }
        else{
            return false
        }

    }
    
    
    // Show ActivityView
    func showActivityView(message: String){
        
        
        // Create BackLight View
        let frame_back = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        let backlight_view = UIView(frame: frame_back)
        backlight_view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        
        backlight_view.tag = 100
        
        self.view.addSubview(backlight_view)
        
        UIView.animate(withDuration: 0.3, animations: {
            backlight_view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.75)
        })

        // Create Activity View
        let frame = CGRect(x: (self.view.frame.width/2) - 25, y:  (self.view.frame.height/2) - 50, width: 50, height: 50)
        
        let activityView = NVActivityIndicatorView(frame: frame,
                                                        type: NVActivityIndicatorType(rawValue: 3)!, color: UIColor.white)
        
        activityView.tag = 101
        
        
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        // Create Label

        let frame_msg = CGRect(x:0, y: 25, width: self.view.frame.width, height: self.view.frame.height)
        let msg_Label = UILabel(frame: frame_msg)
        msg_Label.textColor = UIColor.white
        msg_Label.text = message
        msg_Label.textAlignment = NSTextAlignment.center
        msg_Label.tag = 102
        
        self.view.addSubview(msg_Label)
        
    }
    
    // Hide Activity View
    func hideAcitivityView(message: String){
       
        // Change Label
        let msg_label: UILabel = self.view.viewWithTag(102) as! UILabel
        msg_label.text = message
        
        // Get Other View's
        let back_light: UIView = self.view.viewWithTag(100)!
        let activityView: NVActivityIndicatorView = self.view.viewWithTag(101) as! NVActivityIndicatorView
        
        
        // Remove Acitivity View After 3 Secs
        let delayInSeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            UIView.animate(withDuration: 0.3, animations: { 
                 back_light.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
                 msg_label.removeFromSuperview()
            }, completion: { (Bool) in
            
                activityView.stopAnimating()
                activityView.removeFromSuperview()
                back_light.removeFromSuperview()
            })
           
            
        }
        
        
        
        
        
    }
    

    
}

