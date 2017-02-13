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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        // Calender Delegation
        calender.dataSource = self
        calender.delegate = self
        calender.appearance.headerTitleFont =  UIFont(name: "Raleway-Regular", size: 24)
        calender.appearance.weekdayFont =  UIFont(name: "SourceSansPro-Regular", size: 20)
        calender.appearance.titleFont =  UIFont(name: "SourceSansPro-Regular", size: 14)
        let today = Date()
        calender.select(today)
        
        
        // Slots Animation
        self.slot1_button.alpha = 0
        self.slot2_button.alpha = 0
        self.slot3_button.alpha = 0
        self.slot1_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.slot2_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.slot3_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        //Time Travel Label Setup
        let myStr = "1F60A"
        let str = String(Character(UnicodeScalar(Int(myStr, radix: 16)!)!))
        let final_str = "Hmm, Do you have a time machine? " + str
        self.timeTravelLabel.text = final_str
        self.timeTravelLabel.alpha = 0
        self.timeTravelLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Show Slots
        self.showAllSlotButtons()
    }
    
    func showAllSlotButtons(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.slot1_button.alpha = 1
            self.slot2_button.alpha = 1
            self.slot3_button.alpha = 1
            self.slot1_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.slot2_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.slot3_button.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        }, completion: { (Bool) in
        })
    }
    
    func showTimeTravelLabel(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.timeTravelLabel.alpha = 1
            self.timeTravelLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        }, completion: { (Bool) in
        })
        
    }
    
    func hideAllSlotButtons(reverse: Bool){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.slot1_button.alpha = 0
            self.slot2_button.alpha = 0
            self.slot3_button.alpha = 0
            self.slot1_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.slot2_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.slot3_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.timeTravelLabel.alpha = 0
            self.timeTravelLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
        }, completion: { (Bool) in
            if(reverse){
                self.showAllSlotButtons()
            }
            else{
                self.showTimeTravelLabel()
            }
            
        })
    }
    
    // Calender Date Selection Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let today = Date()
        
        let order = NSCalendar.current.compare(today, to: date, toGranularity: .day)
        
        
        if(date < today && order == .orderedDescending){
            print(date)
            print(today)
            self.hideAllSlotButtons(reverse: false)
            
        }
        else{
            self.hideAllSlotButtons(reverse: true)
        }
        
        
    }
    
    
    
    
}

