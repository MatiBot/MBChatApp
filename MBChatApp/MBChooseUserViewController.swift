//
//  MBChooseUserViewController.swift
//  ChatApp
//
//  Created by Mati Bot on 12/12/2015.
//  Copyright © 2015 Mati Bot. All rights reserved.
//

import UIKit

class MBChooseUserViewController : UIViewController{
    
    @IBAction func choseJim(sender: UIButton) {
        MBServerManager.sharedInstance.setUsername("Jim")
        
        gotoMainViewController()
    }
    
    @IBAction func choseMati(sender: UIButton) {
        MBServerManager.sharedInstance.setUsername("Mati")
        
        gotoMainViewController()
    }
    
    func gotoMainViewController(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let window = appDelegate.window{
            window.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Main")
        }
    }
}
