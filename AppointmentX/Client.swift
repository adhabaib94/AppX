//
//  Client.swift
//  AppointmentX
//
//  Created by Abdullah Al Dhabaib on 1/30/17.
//  Copyright © 2017 Abdullah Al Dhabaib. All rights reserved.
//

import Foundation
import Firebase


class Client : NSObject {
    
    // Base Fields For Client
    var clientID: String = ""
    var email: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName : String = ""
    var phoneNumber: String = ""
    var legalStatus: String = ""
    
    // Client Manager Status Fields/Notications
    var REGISTERATION_STATUS: Bool = false
    
    let CLIENT_REG = "REG_CLIENT"
    let CLIENT_REG_FAILED = "REG_CLIENT_FAILED"
    let CLIENT_REG_EXISTS = "REG_CLIENT_EXISTS"

    
    var AUTHENTICATION_STATUS: Int = 0
    let CLIENT_AUTH = "AUTH_COMPLETE"
    let CLIENT_AUTH_FAILED = "AUTH_FAILED"
    

    let CLIENT_UPDATE = "UPD_CLIENT"
    let CLIENT_UPDATE_FAILED = "UPD_CLIENT_FAILED"
   
    let CLIENT_DELETE = "DEL_CLIENT"
    let CLIENT_DELETE_FAILED = "DEL_CLIENT_FAILED"
    
    
    // Case File Object
    var myCase:Case = Case()
    
    
    
    // Register New Client
    func registerNewClient(firstName: String, lastName: String, email: String ,password: String , number: String, legalStatus: String)  {
        
        print("\n### ClientManager -> Registering New Client Information ###\n")
        

        // Verify Client Email given not used
        _ = FIRDatabase.database().reference().child("Clients").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(FIRDataEventType.value, with: { (snapshot) in
            
            // Remove Observers
            self.removeClientObservers()
            
            // Get Data From Server
            let postDict = snapshot.value as? NSDictionary
            
            // No Client Email found, then return true
            if(postDict == nil){
                print("\t*** ClientManager: Duplicate Email NOT found. ***\n")
                
                // Register Client With Firebase
                
    
                let ref =  FIRDatabase.database().reference()
                let newClientRef = ref.child("Clients").childByAutoId()
                self.clientID = newClientRef.key
                let newClientData = [
                    "clientID" : newClientRef.key,
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "password": password,
                    "phoneNumber": number,
                    "legalStatus": legalStatus]
            
                
                newClientRef.setValue(newClientData, withCompletionBlock:   { (NSError, FIRDatabaseReference) in
                    
                    // Init Client Object
                    
                    self.email = email
                    self.password = password
                    self.firstName = firstName
                    self.lastName = lastName
                    self.phoneNumber = number
                    self.legalStatus = legalStatus
                    
                    print("\t*** ClientManager: Client Object Initialized ***\n")
                    
                    // Client Authenticated and Registered
                    self.REGISTERATION_STATUS = true
                    self.AUTHENTICATION_STATUS = 1
                    
                    DispatchQueue.main.async {
                        // POST NOTIFICATION FOR COMPLETION
                        NotificationCenter.default.post(name: Notification.Name(self.CLIENT_REG), object: nil)
                    }
                  

                    
                })
                
                    print("\t*** ClientManager: Client Informatin Saved To Server ***\n")
                
                
                
            }
            else{
                print("\t*** ClientManager: Duplicate Email found. ***\n")
                self.removeClientObservers()
                
                // POST NOTIFICATION FOR COMPLETION
                DispatchQueue.main.async {
                    // POST NOTIFICATION FOR COMPLETION
                    NotificationCenter.default.post(name: Notification.Name(self.CLIENT_REG_EXISTS), object: nil)
                }
                
        
            }
        
           
            
         })
        
        
        
    }
    
    
    // Authenticate New Client
    func authenticateExistingClient(email: String, password: String) {
        
        print("\n### ClientManager -> Authenticate Client Information ###\n")
        
        
        // Get Client Reference By Email
        _ = FIRDatabase.database().reference().child("Clients").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(FIRDataEventType.value, with: { (snapshot) in
           
            // Get Data From Server
           let postDict = snapshot.value as? NSDictionary
           
            // No Client Found Return Failed to Authenticate
            if(postDict == nil){
                print("\t*** ClientManager: Failed to find user by email. ***\n")
                self.AUTHENTICATION_STATUS = -2 // Failed authenticated Client(email not found)
                self.removeClientObservers()
                // POST NOTIFICATION FOR COMPLETION
                
                
                DispatchQueue.main.async {
                    // POST NOTIFICATION FOR COMPLETION
                    NotificationCenter.default.post(name: Notification.Name(self.CLIENT_AUTH_FAILED), object: nil)
                    
                }
              

            }
            else{
                // Get ClientID
                let clientID = postDict?.allKeys.first as! String
                
                // Get ClientData
                let clientData = postDict?[clientID] as? NSDictionary // array of dictionaries
                
                // Get Client Password
                let clientPassword = clientData!["password"] as! String
                
                if(clientPassword == password){
                    print("\t*** ClientManager: Client sucessfully authentincated! ***\n")
    
                    // Client Authenticated and Registered
                    self.REGISTERATION_STATUS = true
                    self.AUTHENTICATION_STATUS = 1
                    self.removeClientObservers()
                    
                    // Init Client Object
                    self.clientID = clientID
                    self.firstName = clientData!["firstName"] as! String
                    self.lastName = clientData!["lastName"] as! String
                    self.email = clientData!["email"] as! String
                    self.password = clientData!["password"] as! String
                    self.phoneNumber = clientData!["phoneNumber"] as! String
                    self.legalStatus = clientData!["legalStatus"] as! String
                    print("\t*** ClientManager: Client Object Initialized***\n")
                    
                    
                    self.myCase.getCase(clientID: self.clientID)
                    self.printClient()
                    
                    
                    DispatchQueue.main.async {
                        // POST NOTIFICATION FOR COMPLETION
                        NotificationCenter.default.post(name: Notification.Name(self.CLIENT_AUTH), object: nil)
                        
                    }
                    
                    
                    
                }
                else{
                    print("\t*** ClientManager: Client failed to authentincate password! ***\n")
                    self.AUTHENTICATION_STATUS = -1 // Failed authenticated Client(password does not match)
                    self.removeClientObservers()
                    
                    DispatchQueue.main.async {
        
                        // POST NOTIFICATION FOR COMPLETION
                        NotificationCenter.default.post(name: Notification.Name(self.CLIENT_AUTH_FAILED), object: nil)
                        
                    }
                    
              
                
                }
                
            }
          
            
          
        })
    
        
        
    }

    
    // Update Client Information
    func updateClientInformation(){
        
        print("\n### ClientManager -> Updating Client Information ###\n")

        
        let ref  = FIRDatabase.database().reference().child("Clients").child(self.clientID)
        
        ref.updateChildValues([
            "clientID" : self.clientID,
            "firstName": self.firstName,
            "lastName": self.lastName,
            "email": self.email,
            "password": self.password,
            "phoneNumber": self.phoneNumber,
            "legalStatus": self.legalStatus],withCompletionBlock: { (NSError, FIRDatabaseReference) in
                
                
                DispatchQueue.main.async {
                    
                    // POST NOTIFICATION FOR COMPLETION
                    NotificationCenter.default.post(name: Notification.Name(self.CLIENT_UPDATE), object: nil)
                }
                
       
                
                
        })
        

        
        print("\t*** ClientManager: Client Information Updated ***\n")
       
        

    }
    
    
    // Remove Client Account and Information
    func deleteClientAccount(){
        
        
        print("\n### ClientManager -> Deleting Client Information ###\n")
        
        let ref  = FIRDatabase.database().reference().child("Clients").child(self.clientID)
        
        ref.removeValue(completionBlock: { (NSError, FIRDatabaseReference) in
            
            self.firstName = ""
            self.lastName = ""
            self.email = ""
            self.legalStatus = ""
            self.password = ""
            self.phoneNumber = ""
            
            self.AUTHENTICATION_STATUS = 0
            self.REGISTERATION_STATUS = false
            
            if(self.myCase.clientID != ""){
                self.myCase.deleteCase()
            }

            
            DispatchQueue.main.async {
                
                // POST NOTIFICATION FOR COMPLETION
                NotificationCenter.default.post(name: Notification.Name(self.CLIENT_DELETE), object: nil)
                
            }
            
            
            
        })

        
        print("\t*** ClientManager: Client Information Deleted ***\n")
  
        
    }
    
    
    // Detach any unhandled reference queries
    func removeClientObservers(){
        FIRDatabase.database().reference().child("Clients").removeAllObservers()
    }
    
    func printClient(){
        print("\n*** ClientManager: printing client summary... ***\n")
        print("\tclientID:\(self.clientID)\n\tclientName:\(self.firstName) \(self.lastName)\n\t")
    }
    
    

}
