//
//  Case.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 1/31/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import Foundation
import Firebase


class Case: NSObject {
    
    // Case Base Variables
    var caseID:String = ""
    var caseStatus:String = ""
    var platform:String = "" // ios = o || andriod = a -> xx ... ex: ox, xa, oa
    var appName: String = ""
    var appDescription: String = ""
    var appFeatures: String = ""
    var deadline: String = ""
    var clientID: String = ""
    
    // Case Manager Notfication Variables

    let CREATE_CASE = "CREATE_CASE"
    let UPDATE_CASE = "UPDATE_CASE"
    let DELETE_CASE = "DELETE_CASE"
    let GET_CASE = "APPT_GET"

    
    var caseExists = false
    
    // Case Scheduler
    var scheduler:Scheduler = Scheduler()
    
    
    // Create Case File For Client
    func createCase(caseStatus: String, platform: String, appName: String, appDescription: String, appFeatures: String, deadline: String, clientID: String){
        
        print("\t*** CaseManager: Creating new Case for Client ***\n")
        
        // Save Data to Server
        let ref =  FIRDatabase.database().reference()
        let newCaseRef = ref.child("Cases").childByAutoId()
        self.caseID = newCaseRef.key
        let newCaseData = [
            "caseID" : newCaseRef.key,
            "caseStatus": caseStatus,
            "platform": platform,
            "appName": appName,
            "appDescription": appDescription,
            "appFeatures": appFeatures,
            "deadline": deadline,
            "clientID" : clientID]
        
        newCaseRef.setValue(newCaseData,withCompletionBlock:   { (NSError, FIRDatabaseReference) in
            
            // Save Data to Case Object
            self.caseStatus = caseStatus
            self.platform = platform
            self.appName = appName
            self.appFeatures = appFeatures
            self.appDescription = appDescription
            self.deadline = deadline
            self.clientID = clientID
            
            // Include Scheuler Init
            self.scheduler.clientID = self.clientID
            self.scheduler.caseID = self.caseID
            
            // Verify Case Exists
            self.caseExists = true
            
            
            print("\t*** CaseManager: Case created/saved to Server for Client ***\n")
            
            // POST NOTIFICATION FOR COMPLETION
            DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(self.CREATE_CASE), object: nil)
            }
            
            
        })

        
       
        
    }
    
    // Update Case File For Client
    func updateCase(){
        
        print("\n### CaseManager -> Updating Case Information ###\n")
        
        
        let ref  = FIRDatabase.database().reference().child("Cases").child(self.caseID)
        
        

        ref.updateChildValues([
                "caseID" : self.caseID,
                "caseStatus": self.caseStatus,
                "platform": self.platform,
                "appName": self.appName,
                "appDescription": self.appDescription,
                "appFeatures": self.appFeatures,
                "deadline": self.deadline,
                "clientID" : self.clientID], withCompletionBlock: { (NSError, FIRDatabaseReference) in //update the book in the db
             
               
                    // POST NOTIFICATION FOR COMPLETION
                    DispatchQueue.main.async {
                         NotificationCenter.default.post(name: Notification.Name(self.UPDATE_CASE), object: nil)
                    }
                    
        })
  
            
            
        print("\t*** CaseManager: Case Information Updated ***\n")
        
        
    
        
        
        
        
    }
    
    // Delete Case File For Client
    func deleteCase(){
        print("\n### CaseManager -> Deleting Case Information ###\n")
        
        let ref  = FIRDatabase.database().reference().child("Cases").child(self.caseID)
        
        ref.removeValue(completionBlock: { (NSError, FIRDatabaseReference) in
            
            self.caseID = ""
            self.caseStatus = ""
            self.platform = ""
            self.appName = ""
            self.appFeatures = ""
            self.appDescription = ""
            self.deadline = ""
            self.clientID = ""
            self.caseExists = false
            
            self.scheduler.cancelScheduledAppointment()
            
            print("\t*** CaseManager: Case Information Deleted ***\n")
            
        
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.DELETE_CASE), object: nil)

            }
            
        })

        
        
        
    }
    
    // Get Case File For Client
    func getCase(clientID: String){
        _ = FIRDatabase.database().reference().child("Cases").queryOrdered(byChild:"clientID").queryEqual(toValue: clientID).observe(FIRDataEventType.value, with: { (snapshot) in
            
            // Remove Observers
             self.removeCaseObservers()
            
            // Get Data From Server
            let postDict = snapshot.value as? NSDictionary
            
            // No Case Found Return Failed to Find
            if(postDict == nil){
                print("\n*** CaseManager: No Cases found for Client. ***\n")
               
            }
            else{
                // Get caseID
                let caseID = postDict?.allKeys.first as! String
                
                // Get caseData
                let caseData = postDict?[caseID] as? NSDictionary // array of dictionaries
                
                print("\n*** CaseManager: Case sucessfully found! ***\n")
                
                // Init Case Object
                self.caseID = caseID
                self.clientID = clientID
                self.appName = caseData!["appName"] as! String
                self.appDescription = caseData!["appDescription"] as! String
                self.appFeatures  = caseData!["appFeatures"] as! String
                self.platform = caseData!["platform"] as! String
                self.caseStatus = caseData!["caseStatus"] as! String
                self.deadline = caseData!["deadline"] as! String
                self.caseExists = true
                
                print("\t*** CaseManager: Case Object Initialized***\n")
                
                self.printCase()
                
                
                // Get Scheduled Appointments
                self.scheduler.clientID = self.clientID
                self.scheduler.caseID = self.caseID
                self.scheduler.getScheduledAppointment()

            }
            
            DispatchQueue.main.async {
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.GET_CASE), object: nil)
                
            }

    
            
        })
        
        
        
    }
    
    // Detach any unhandled reference queries
    func removeCaseObservers(){
        FIRDatabase.database().reference().child("Cases").removeAllObservers()
    }
    
    // Print Case File
    func printCase(){
        print("\n*** CaseManager: Print Case Summary....\n")
        print("\tcaseID:\(self.caseID)\n\tclientID:\(self.clientID)\n\tappName:\(self.appName)\n\t")
    }
    
    
    
    
}
