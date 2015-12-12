//
//  MBChatViewController.swift
//  ChatApp
//
//  Created by Mati Bot on 12/12/2015.
//  Copyright © 2015 Mati Bot. All rights reserved.
//

import Parse
import UIKit

class MBChatViewController : UIViewController, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate{
    
    //MARK: IBOutlets
    
    @IBOutlet weak var bottomBarView: UIVisualEffectView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messages = Array<PFObject>()
    
    let name = MBServerManager.sharedInstance.username()
    
    //MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        registerForKeyboardNotifications()
        
        loadMessages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
        scrollToEnd(false)
    }
    
    func initTableView(){
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.bottomBarView.frame.size.height, right: 0)
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChange:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChange:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillChange(notification:NSNotification){
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as! NSTimeInterval
        
        let options = UIViewAnimationOptions(rawValue: UInt((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
        
        var height = 0 as CGFloat
        
        if(notification.name == UIKeyboardWillShowNotification){
            height = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue.height
        }else{
            height = 0
        }
        
        self.bottomConstraint.constant = height
        
        UIView.animateWithDuration(duration, delay: 0, options: options, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: self.bottomBarView.frame.size.height + height, right: 0)
            
            if(height > 0){
                self.scrollToEnd(true)
            }
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    
    func loadMessages(){
        
        let lastMessage = self.messages.last
        
        MBServerManager.sharedInstance.getMessages(lastMessage?.createdAt, maxNumber: 1000) { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if objects?.count > 0 {
                
                CATransaction.begin()
                
                CATransaction.setCompletionBlock({ () -> Void in
                    self.scrollToEnd(true)
                    
                    self.performSelector("loadMessages", withObject: nil, afterDelay: 1)
                })
                
                self.tableView?.beginUpdates()
                
                var indexPaths = Array<NSIndexPath>()
                var lastIndex = self.messages.count
                
                for object in objects!{
                    self.messages.append(object)
                    indexPaths.append(NSIndexPath(forItem: lastIndex, inSection: 0))
                    
                    lastIndex++
                }
                
                self.tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
                
                self.tableView?.endUpdates()
                
                CATransaction.commit()
            }else{
                self.performSelector("loadMessages", withObject: nil, afterDelay: 1)
            }
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
        
        if(self.messageTextField.isFirstResponder() && abs(velocity.y) >= 2.5){
            self.messageTextField.resignFirstResponder()
        }
    }
    
    func scrollToEnd(animated:Bool){
        if(self.messages.count > 0){
            print("scroll to bottom")
            self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count-1, inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let from = self.messages[indexPath.row].objectForKey(MBServerManager.FROM_FIELD) as! String
        let msg = self.messages[indexPath.row].objectForKey(MBServerManager.MESSAGE_FIELD) as! String
        
        var cell : MBChatBubbleTableViewCell? = nil
        
        if(name == from){
            cell = tableView.dequeueReusableCellWithIdentifier(MBChatBubbleTableViewCell.OUTCOMING_REUSEIDETIFIER) as? MBChatBubbleTableViewCell
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier(MBChatBubbleTableViewCell.INCOMING_REUSEIDETIFIER) as? MBChatBubbleTableViewCell
        }
        
        cell?.setMsg(msg)
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let msg = self.messages[indexPath.row].objectForKey(MBServerManager.MESSAGE_FIELD) as! String
        
        return MBChatBubbleTableViewCell.getSizeForMsg(msg).height
    }
    
    func sendMessage()->Bool{
        
        let text = self.messageTextField.text
        
        self.messageTextField.text = ""
        self.sendButton.enabled = false
        
        MBServerManager.sharedInstance.sendMessage(self.name, msg: text, block: nil)
        
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return sendMessage()
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        sendMessage()
    }
    
    @IBAction func didEditingChanged(sender: AnyObject) {
        self.sendButton.enabled = !(self.messageTextField.text == nil || self.messageTextField.text!.characters.count == 0)
    }
    
    deinit{
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
