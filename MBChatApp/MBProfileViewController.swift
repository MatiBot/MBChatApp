//
//  MBProfileViewController.swift
//  ChatApp
//
//  Created by Mati Bot on 12/12/2015.
//  Copyright © 2015 Mati Bot. All rights reserved.
//

import UIKit

class MBProfileViewController : UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = MBServerManager.sharedInstance.username()
        
        profileImageView.image = UIImage(named: name)
        nameLabel.text = name
    }
    
}