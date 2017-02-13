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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        calender.select(today)
        
        
        // Slots Animation
        self.slot1_button.alpha = 0
        self.slot2_button.alpha = 0
        self.slot3_button.alpha = 0
        self.slot1_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.slot2_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.slot3_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        

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
    
    func hideAllSlotButtons(){
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.slot1_button.alpha = 0
            self.slot2_button.alpha = 0
            self.slot3_button.alpha = 0
            self.slot1_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.slot2_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.slot3_button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
        }, completion: { (Bool) in
            self.showAllSlotButtons()
        })
    }
    
    // Calender Date Selection Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       self.hideAllSlotButtons()
    }

    
    
    
}

