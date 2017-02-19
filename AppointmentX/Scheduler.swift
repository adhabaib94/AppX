//
//  Scheduler.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 1/31/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import Foundation
import Firebase


class Scheduler: NSObject {
    
    // Base Variables
    var clientID:String = ""
    var caseID:String = ""
    var myAppointment:Appointment = Appointment()
    
    // Schedueling Variables
    var availableSlots = [true,true,true]
    
    // Notification Variables
    let SCH_FETCHED_SLOTS = "SCH_FETCH_COMPLETE"
    
    // Schedule Appointment For Case and Client
    
    func scheduleAppointment(date: String, time: String, slot:String, info: String){
        // Create Appoitnment Object
        self.myAppointment.createAppointment(date: date, time: time, info: info, slot: slot, caseID: self.caseID, clientID: self.clientID)
        print("\n*** Scheduler: Appointment scheuduled. ***\n")
        
    }
    
    
    // Retrieve Scheudueled Appointment
    func getScheduledAppointment(){
        self.myAppointment.getAppointment(caseID: self.caseID)
        
        
        
        
    }
    
    
    // Delete Scheudled Appointment
    func cancelScheduledAppointment(){
        if(self.myAppointment.appointmentExists){
            self.myAppointment.deleteAppointment()
        }
    }
    
    // Update Schueduled Appointment
    func alterSchueledAppointment(){
        self.myAppointment.updateAppointment()
    }
    
    
    // Get Available Appointment Slots At Given Day
    func getAvailableAppointmentSlots(day: String){
        
        // Refresh Available Slots
        self.availableSlots = [true,true,true,true]
        
        // Create Reference To Appointments
        _ = FIRDatabase.database().reference().child("Appointments").queryOrdered(byChild:"date").queryEqual(toValue: day).observe(FIRDataEventType.value, with: { (snapshot) in
            
            // Get Data From Server
            let fetchedData = snapshot.value as? NSDictionary
            
            // No Appointment Found Return Failed to Find Appointment
            if(fetchedData == nil){
                print("\n*** ScheuleManager: No Appointments found for Day. ***\n")
                self.removeAppointmentsObservers()
                
            }
                
                // Booked Appointments Found, Retreive there allocated slots and update Available Slots
            else{
                
                print("\n*** ScheuleManager: Found Appointments Booked. ***\n")
                for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let current_appt = rest.value as? NSDictionary
                    let current_slot = Int(current_appt!["slot"] as! String)
                    self.availableSlots[current_slot!-1] = false
                    
                }
                self.removeAppointmentsObservers()
            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.SCH_FETCHED_SLOTS), object: nil)
                
                
            }
            
        })
        
    }
    
    // Detach any unhandled reference queries
    func removeAppointmentsObservers(){
        FIRDatabase.database().reference().child("Appointments").removeAllObservers()
    }
    
    
    
}
