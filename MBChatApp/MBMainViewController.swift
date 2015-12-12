//
//  MainViewController.swift
//  ChatApp
//
//  Created by Mati Bot on 12/12/2015.
//  Copyright © 2015 Mati Bot. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    
    // MARK: Consts
    
    static let ANIMATION_OPEN_TIME_SEC : NSTimeInterval = 0.2
    static let ANIMATION_CLOSE_TIME_SEC : NSTimeInterval = 0.2
    static let CHANGE_STATE_XDELTA_THRESHOLD : CGFloat = 20
    static let RIGHT_SCREEN_EDGE_OFFSET : CGFloat = 100
    
    static let NAV_DRAWER_SEGUE_IDENTIFIER = "NavigationDrawerViewController"
    static let CONENT_SEGUE_IDENTIFIER = "CONTENT"
    
    static let PROFILE_STORYBOARD_IDENTIFIER = "PROFILE"
    static let CHAT_STORYBOARD_IDENTIFIER = "CHAT"
    static let SETTINGS_STORYBOARD_IDENTIFIER = "SETTINGS"
    
    static let PROFILE_CELL_REUSE_IDENTIFIER = "MBProfileTableViewCell"
    static let ROW_CELL_REUSE_IDENTIFIER = "MBNavigationRowTableViewCell"
    
    static let viewControllerIdentifierArray = [MainViewController.PROFILE_STORYBOARD_IDENTIFIER,MainViewController.CHAT_STORYBOARD_IDENTIFIER,MainViewController.SETTINGS_STORYBOARD_IDENTIFIER]
    
    // MARK: Outlets
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var navigationDrawerViewController : UITableViewController?
    var contentViewController : UIViewController?
    
    var startPoint : CGPoint?
    var isStartedOpen = false
    
    //the offset of the content view from the right size of the screen. needs to be calculated after the view was loaded
    var rightScreenOffset : CGFloat = 0
    
    
    var viewControllerDictionary = NSCache()
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rightScreenOffset = CGRectGetWidth(self.view.frame) - MainViewController.RIGHT_SCREEN_EDGE_OFFSET
        
        for identifier in MainViewController.viewControllerIdentifierArray{
            self.viewControllerForIdentifier(identifier)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier!.isEqual(MainViewController.NAV_DRAWER_SEGUE_IDENTIFIER)){
            self.navigationDrawerViewController = segue.destinationViewController as? UITableViewController
            self.initDrawer(self.navigationDrawerViewController!)
        }else if(segue.identifier!.isEqual(MainViewController.CONENT_SEGUE_IDENTIFIER
            )){
                self.contentViewController = segue.destinationViewController;
        }
    }
    
    func initDrawer(tableViewController:UITableViewController){
        self.navigationDrawerViewController?.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationDrawerViewController?.tableView.estimatedRowHeight = 160.0
        self.navigationDrawerViewController?.tableView.dataSource = self;
        self.navigationDrawerViewController?.tableView.delegate = self;
        self.navigationDrawerViewController?.tableView.reloadData()
        self.navigationDrawerViewController?.tableView.tableFooterView = UIView()
    }
    
    // MARK: Gesture Recognizer
    
    @IBAction func didPanOnContent(sender: UIPanGestureRecognizer) {
        
        let currentPoint = sender.translationInView(self.view)
        let newX = startPoint != nil ? max(0 ,(self.isStartedOpen ? self.rightScreenOffset : 0) + currentPoint.x - startPoint!.x) : 0;
        
        switch(sender.state){
        case .Began:
            isStartedOpen = isDrawerOpen()
            startPoint = currentPoint
            
            break
            
        case .Changed:
            self.contentView.transform = CGAffineTransformMakeTranslation(newX, 0)
            
        case  .Ended:
            
            if(self.isStartedOpen){
                if(newX < self.rightScreenOffset - MainViewController.CHANGE_STATE_XDELTA_THRESHOLD){
                    closeNavigationDrawer()
                }else{
                    openNavigationDrawer()
                }
            }else{
                if(newX < MainViewController.CHANGE_STATE_XDELTA_THRESHOLD){
                    closeNavigationDrawer()
                }else{
                    openNavigationDrawer()
                }
            }
            
            break
            
        default: //case .Failed, .Cancelled:
            closeNavigationDrawer()
            
            break
        }
    }
    
    // MARK: Drawer operations
    
    func openNavigationDrawer(){
        UIView.animateWithDuration(MainViewController.ANIMATION_OPEN_TIME_SEC, animations: { () -> Void in
            
            self.panGestureRecognizer.enabled = false
            self.contentView.transform = CGAffineTransformMakeTranslation(self.rightScreenOffset, 0)
            
            }) { (isCompleted:Bool) -> Void in
                
                self.panGestureRecognizer.enabled = true
        }
    }
    
    func closeNavigationDrawer(){
        UIView.animateWithDuration(MainViewController.ANIMATION_CLOSE_TIME_SEC, animations: { () -> Void in
            
            self.panGestureRecognizer.enabled = false
            self.contentView.transform = CGAffineTransformIdentity
            
            }) { (isCompleted:Bool) -> Void in
                
                self.panGestureRecognizer.enabled = true
        }
    }
    
    func isDrawerOpen()->Bool{
        
        return !CGAffineTransformIsIdentity(self.contentView.transform)
    }
    
    
    func viewControllerForIdentifier(identifier:String)->UIViewController?{
        
        var vc = self.viewControllerDictionary.objectForKey(identifier) as? UIViewController
        
        if(vc == nil){
            vc = self.storyboard?.instantiateViewControllerWithIdentifier(identifier)
            self.viewControllerDictionary.setObject(vc!, forKey: identifier)
        }
        
        return vc!
    }
    
    func changeContentViewController(vc:UIViewController?){
        vc?.view.layoutIfNeeded()
        self.addChildViewController(vc!)
        self.transitionFromViewController(self.contentViewController!, toViewController: vc!, duration: MainViewController.ANIMATION_CLOSE_TIME_SEC, options: .TransitionCrossDissolve, animations: { () -> Void in
            self.contentViewController?.removeFromParentViewController()
            vc?.didMoveToParentViewController(self)
            
            }) { (completion:Bool) -> Void in
                self.closeNavigationDrawer()
                self.contentViewController = vc
        }
    }
    
    // MARK: UITableView Datasource
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return MainViewController.viewControllerIdentifierArray.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell : UITableViewCell? = nil
        
        
        var reuseIdentifier : String
        
        if(MainViewController.viewControllerIdentifierArray[indexPath.item] == MainViewController.PROFILE_STORYBOARD_IDENTIFIER){
            reuseIdentifier = MainViewController.PROFILE_CELL_REUSE_IDENTIFIER
        }else{
            reuseIdentifier = MainViewController.ROW_CELL_REUSE_IDENTIFIER
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
        
        if(cell!.isKindOfClass(MBProfileTableViewCell)){
            let profileCell = cell as! MBProfileTableViewCell
            let name = MBServerManager.sharedInstance.username()
            
            profileCell.profileImageView.image = UIImage(named: name)
            profileCell.nameLabel.text = name
            
        }else if(cell!.isKindOfClass(MBNavigationRowTableViewCell)){
            let rowCell = cell as! MBNavigationRowTableViewCell
            rowCell.titleLabel.text = viewControllerForIdentifier(MainViewController.viewControllerIdentifierArray[indexPath.row])?.title
        }
        
        return cell!
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let identifier = MainViewController.viewControllerIdentifierArray[indexPath.item]
        
        let vc = viewControllerForIdentifier(identifier)
        
        //Same view controller was selected
        if(vc == self.contentViewController){
            self.closeNavigationDrawer()
            return
        }
        
        if(identifier == MainViewController.CHAT_STORYBOARD_IDENTIFIER){
            let mainNavVC = vc as! UINavigationController
            let chatVC = mainNavVC.topViewController as! MBChatViewController
            MBServerManager.sharedInstance.getMessages(nil, maxNumber: 1000, block: { (
                objects:[PFObject]?, error:NSError?) -> Void in
                if(objects != nil){
                    chatVC.messages = objects!
                }
                
                self.changeContentViewController(vc)
            })
        }else{
            self.changeContentViewController(vc)
        }
    }
    
}


