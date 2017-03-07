//
//  ScheduleAppointmentController.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 2/7/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import UIKit
import SwiftGifOrigin


class ScheduleAppointmentController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var slot1_button: UIButton!
    @IBOutlet weak var slot3_button: UIButton!
    @IBOutlet weak var slot2_button: UIButton!
    @IBOutlet weak var timeTravelLabel: UILabel!
    
    @IBOutlet weak var reserveAppointmentButton: UIButton!
    // Client Vars
    var current_client:Client!
    let SCH_FETCHED_SLOTS = "SCH_FETCH_COMPLETE"
    let APPT_NOTIFICATION_CREATE = "APPT_CREATED"
    var day_selection = "N/A"
    var time_selection = "N/A"
    var slot_selection = "N/A"
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        // Scheduler Notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAllSlotButtons), name: Notification.Name(SCH_FETCHED_SLOTS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.doneBookingAppointment), name: Notification.Name(APPT_NOTIFICATION_CREATE), object: nil)
        
        
        // Calender Delegation
        calender.dataSource = self
        calender.delegate = self
        calender.appearance.headerTitleFont =  UIFont(name: "Raleway-Regular", size: 24)
        calender.appearance.weekdayFont =  UIFont(name: "SourceSansPro-Regular", size: 20)
        calender.appearance.titleFont =  UIFont(name: "SourceSansPro-Regular", size: 14)
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
        calender.select(tomorrow)
        
        
        // Slots Animation
        self.slot1_button.alpha = 0
        self.slot2_button.alpha = 0
        self.slot3_button.alpha = 0
        self.slot1_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.slot2_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.slot3_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        
        //Time Travel Label Setup
        let myStr = "1F643"
        let str = String(Character(UnicodeScalar(Int(myStr, radix: 16)!)!))
        let final_str = "No Available Appointments On This Day " + str
        self.timeTravelLabel.text = final_str
        self.timeTravelLabel.alpha = 0
        self.timeTravelLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        
        // Refresh Selection
        self.reserveAppointmentButton.alpha = 0.35
        self.reserveAppointmentButton.isEnabled = false
        
        // Select daySelection
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let date_selected = dateformatter.string(from: tomorrow!)
        self.day_selection = date_selected
        
        self.slot_selection = "N/A"
        self.time_selection = "N/A"
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.current_client.myCase.scheduler.getAvailableAppointmentSlots(day: self.day_selection)
    }
    
    
    
    func doneBookingAppointment(){
        
        self.performSegue(withIdentifier: "rootViewController-new", sender: nil)
        
    }
    
    func showAllSlotButtons(){
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
           
            if(self.current_client.myCase.scheduler.availableSlots[0]){
                self.slot1_button.alpha = 1
                self.slot1_button.isEnabled = true
                self.slot1_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            else{
                self.slot1_button.alpha = 0.3
                self.slot1_button.isEnabled = false
                self.slot1_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
            if(self.current_client.myCase.scheduler.availableSlots[1]){
                self.slot2_button.alpha = 1
                self.slot2_button.isEnabled = true
                self.slot2_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            else{
                self.slot2_button.alpha = 0.3
                self.slot2_button.isEnabled = false
                self.slot2_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
            if(self.current_client.myCase.scheduler.availableSlots[2]){
                self.slot3_button.alpha = 1
                self.slot3_button.isEnabled = true
                self.slot3_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            else{
                self.slot3_button.alpha = 0.3
                self.slot3_button.isEnabled = false
                self.slot3_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
        }, completion: { (Bool) in
        })
    }
    
    func showTimeTravelLabel(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.timeTravelLabel.alpha = 1
            self.timeTravelLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            // Refresh Selection
            self.reserveAppointmentButton.alpha = 0.35
            self.reserveAppointmentButton.isEnabled = false
            self.day_selection = "N/A"
            self.slot_selection = "N/A"
            self.time_selection = "N/A"
            
        }, completion: { (Bool) in
        })
        
    }
    
    func hideAllSlotButtons(reverse: Bool){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
           
            self.slot1_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
            self.slot2_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
            self.slot3_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
            
            self.slot1_button.alpha = 0
            self.slot2_button.alpha = 0
            self.slot3_button.alpha = 0
            self.slot1_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.slot2_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.slot3_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.timeTravelLabel.alpha = 0
            self.timeTravelLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            // Refresh Selection
            self.reserveAppointmentButton.alpha = 0.35
            self.reserveAppointmentButton.isEnabled = false
            self.day_selection = "N/A"
            self.slot_selection = "N/A"
            self.time_selection = "N/A"
            
            
            
        }, completion: { (Bool) in
            if(!reverse){
          
                self.showTimeTravelLabel()
            }
            
        })
    }
    
    // Calender Date Selection Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // Today
        let today = Date()
        
        // Select daySelection
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let date_selected = dateformatter.string(from: date)
        
        
        if(date < today ){
            self.hideAllSlotButtons(reverse: false)
            
        }
        else{
            self.current_client.myCase.scheduler.getAvailableAppointmentSlots(day: date_selected)
            self.hideAllSlotButtons(reverse: true)
            self.day_selection = date_selected
        }
        
        
    }
    
    @IBAction func selectedSlot1(_ sender: Any) {
        
        self.reserveAppointmentButton.alpha = 1
        self.reserveAppointmentButton.isEnabled = true
        self.slot_selection = "1"
        self.time_selection = "10:00am"
        self.slot1_button.setBackgroundImage(UIImage.init(named:"small_button_sel"), for: .normal)
        self.slot2_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
        self.slot3_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
    }
    
    @IBAction func selectedSlot2(_ sender: Any) {
        
        self.reserveAppointmentButton.alpha = 1
        self.reserveAppointmentButton.isEnabled = true
        self.slot_selection = "2"
        self.time_selection = "4:00pm"
        self.slot1_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
        self.slot2_button.setBackgroundImage(UIImage.init(named:"small_button_sel"), for: .normal)
        self.slot3_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
        
    }
    
    @IBAction func selectedSlot3(_ sender: Any) {
        
        self.reserveAppointmentButton.alpha = 1
        self.reserveAppointmentButton.isEnabled = true
        self.slot_selection = "3"
        self.time_selection = "7:00pm"
        self.slot1_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
        self.slot2_button.setBackgroundImage(UIImage.init(named:"small_button"), for: .normal)
        self.slot3_button.setBackgroundImage(UIImage.init(named:"small_button_sel"), for: .normal)
        
    }
  
    @IBAction func reserveAppointment(_ sender: Any) {
        
        if(self.day_selection != "N/A" && self.slot_selection != "N/A" && self.time_selection != "N/A"){
             current_client.myCase.scheduler.scheduleAppointment(date: self.day_selection, time: self.time_selection, slot: self.slot_selection, info: "Consulation")
           
            let day = self.day_selection
            self.hideAllSlotButtons(reverse: true)
            self.current_client.myCase.scheduler.getAvailableAppointmentSlots(day: day)
        }
        
    }
}

