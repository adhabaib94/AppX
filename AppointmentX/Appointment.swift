//
//  Appointment.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 1/31/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import Foundation
import Firebase

class Appointment: NSObject {
    
    
    // Basic Variables
    var appointmentID: String = ""
    var date: String = ""
    var time: String = ""
    var info: String = ""
    var slot: String = ""
    var caseID: String = ""
    var clientID: String = ""
    
    //AppointmentMananger Variables For Notification
    let APPT_NOTIFICATION_CREATE = "APPT_CREATED"
    let APPT_NOTIFICATION_UPDATED = "APPT_UPDATED"
    let APPT_NOTIFICATION_DELETED = "APPT_DELETED"
    let APPT_NOTIFICATION_GET = "APPT_GET"
    
    var appointmentExists = false;
    
    // Schedule and Create Appointment
    
    func createAppointment(date: String,time:String,  info: String, slot: String, caseID: String, clientID: String ){
        
        
        print("\t*** AppointmentManager: Creating new Appoitnment for Client ***\n")
        
        // Save Data to Server
        let ref =  FIRDatabase.database().reference()
        let newAppointmentRef = ref.child("Appointments").childByAutoId()
        self.appointmentID = newAppointmentRef.key
        let newAppointmentData = [
            "appointmentID" : newAppointmentRef.key,
            "date": date,
            "time": time,
            "info": info,
            "slot": slot,
            "caseID": caseID,
            "clientID" : clientID]
        
        newAppointmentRef.setValue(newAppointmentData,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            // Init Appointment Object
            self.date = date
            self.time = time
            self.info = info
            self.caseID = caseID
            self.clientID = clientID
            self.slot = slot
            self.appointmentExists = true
            
            print("\t*** AppointmentManager: Appoitnment created/saved to Server for Client ***\n")
            
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.APPT_NOTIFICATION_CREATE), object: nil)
            }
            
            
        })
        
        
    }
    
    
    // Update and Alter Appointment
    func updateAppointment(){
        print("\n### AppoitnmentManager -> Updating Appoitnment Information ###\n")
        
        
        let ref  = FIRDatabase.database().reference().child("Appointments").child(self.appointmentID)
        
        ref.updateChildValues([
            "appointmentID" : self.appointmentID,
            "date": date,
            "time": time,
            "info": info,
            "slot": slot,
            "caseID": caseID,
            "clientID" : clientID]
            
            , withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
                
                
                // POST NOTIFICATION FOR COMPLETION
                DispatchQueue.main.async {
                    // POST NOTIFICATION FOR COMPLETION
                    NotificationCenter.default.post(name: Notification.Name(self.APPT_NOTIFICATION_UPDATED), object: nil)
                    
                }
                
                
                
        })
        
        
        print("\t*** AppointmentManager: Appoitnment Information Updated ***\n")
        
        
    }
    
    // Cancel and Delete Appointment
    func deleteAppointment(){
        print("\n### AppointmentManager -> Deleting Appointment Information ###\n")
        
        let ref  = FIRDatabase.database().reference().child("Appointments").child(self.appointmentID)
        
        ref.removeValue(completionBlock: { (NSError, FIRDatabaseReference) in
            
            
            self.appointmentID = ""
            self.date = ""
            self.time = ""
            self.info = ""
            self.caseID = ""
            self.clientID = ""
            self.slot = ""
            
            self.appointmentExists = false
            
            print("\t*** AppointmentManager: Appoitnment Information Deleted ***\n")
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.APPT_NOTIFICATION_DELETED), object: nil)
                
                
                
            }
            
        })
        
    }
    
    
    
    // Get Appointment For Case
    func getAppointment(caseID: String){
        _ = FIRDatabase.database().reference().child("Appointments").queryOrdered(byChild:"caseID").queryEqual(toValue: caseID).observe(FIRDataEventType.value, with: { (snapshot) in
            
            // Remove Observer
            self.removeAppointmentsObservers()
            
            // Get Data From Server
            let postDict = snapshot.value as? NSDictionary
            
            // No Appointment Found Return Failed to Find Appointment
            if(postDict == nil){
                print("\n*** AppointmentManager: No Appointments found for Case. ***\n")
       
            }
            else{
                // Get AppointmentID
                let appointmentID = postDict?.allKeys.first as! String
                
                // Get AppointmentData
                let appointmentData = postDict?[appointmentID] as? NSDictionary // array of dictionaries
                
                print("\n*** AppointmentManager: Appoitnment sucessfully found! ***\n")
                
                // Init Appoitnment Object
                self.appointmentID = appointmentID
                self.date = appointmentData!["date"] as! String
                self.time = appointmentData!["time"] as! String
                self.info = appointmentData!["info"] as! String
                self.slot = appointmentData!["slot"] as! String
                self.caseID = appointmentData!["caseID"] as! String
                self.clientID = appointmentData!["clientID"] as! String
                self.appointmentExists = true
                
                print("\t*** AppointmentManager: Appointment Object Initialized***\n")
                
                self.printAppointment()

            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.APPT_NOTIFICATION_GET), object: nil)

            }

            
            
        })
        
        
        
    }
    
    // Print Case File
    func printAppointment(){
        print("\n*** AppointmentManager: Print Appointment Summary....\n")
        print("\tappointmentID:\(self.appointmentID)\n\tdateID:\(self.date)\n\ttime:\(self.time) ...\n\t")
    }
    
    // Detach any unhandled reference queries
    func removeAppointmentsObservers(){
        FIRDatabase.database().reference().child("Appointments").removeAllObservers()
    }
    
    
    
    
}
