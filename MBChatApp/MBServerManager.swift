//
//  MBServerManager.swift
//  ChatApp
//
//  Created by Mati Bot on 12/12/2015.
//  Copyright © 2015 Mati Bot. All rights reserved.
//

import Foundation
import Parse

class MBServerManager {
    
    static let PARSE_APP_ID = "x55iLyX15nmC54wkpDMaoPtMYgZC5OiJ6fw4iJbD"
    static let PARSE_CLIENT_KEY = "Jz3YssYxkHm0Oxp34DqQRo8do55kWWVl8v7bjKF7"
    
    static let MESSAGE_CLASS = "Message"
    static let CREATED_AT_FIELD = "createdAt"
    static let FROM_FIELD = "from"
    static let MESSAGE_FIELD = "message"
    
    static let USERNAME_KEY = "User"
    
    static let sharedInstance = MBServerManager()
    
    init(){
        
    }
    
    func initServerConnection(){
        // Initialize Parse.
        Parse.setApplicationId(MBServerManager.PARSE_APP_ID,
            clientKey: MBServerManager.PARSE_CLIENT_KEY)
    }
    
    func getMessages(fromDate:NSDate?, maxNumber:Int, block: PFQueryArrayResultBlock?){
        
        let query = PFQuery(className: MBServerManager.MESSAGE_CLASS)
        query.orderByAscending(MBServerManager.CREATED_AT_FIELD)
        
        if(fromDate != nil){
            query.whereKey(MBServerManager.CREATED_AT_FIELD, greaterThan:fromDate! )
        }
        
        query.limit = 1000
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if(block != nil){
                block!(objects,error)
            }
        }
    }
    
    func sendMessage(from:String, msg:String?, block: PFBooleanResultBlock?){
        
        if(msg != nil && msg!.characters.count > 0){
            
            let object = PFObject(className: MBServerManager.MESSAGE_CLASS)
            object[MBServerManager.FROM_FIELD] = from
            object[MBServerManager.MESSAGE_FIELD] = msg!
            
            object.saveInBackgroundWithBlock(block)
        }
    }
    
    func setUsername(username:String){
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: MBServerManager.USERNAME_KEY)
    }
    
    func username()->String{
        return NSUserDefaults.standardUserDefaults().stringForKey(MBServerManager.USERNAME_KEY)!
    }
}