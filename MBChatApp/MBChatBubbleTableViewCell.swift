//
//  MBChatBubbleTableViewCell.swift
//  ChatApp
//
//  Created by Mati Bot on 12/12/2015.
//  Copyright © 2015 Mati Bot. All rights reserved.
//

import UIKit


class MBChatBubbleTableViewCell : UITableViewCell{
    
    static let OUTCOMING_REUSEIDETIFIER = "OUTCOMING"
    static let INCOMING_REUSEIDETIFIER = "INCOMING"
    static let INCOMING_BUBBLE = "INCOMING_BUBBLE"
    static let OUTCOMING_BUBBLE = "OUTCOMING_BUBBLE"
    
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var msgLabel: UILabel!
    
    override func awakeFromNib() {
        if(self.reuseIdentifier == MBChatBubbleTableViewCell.OUTCOMING_REUSEIDETIFIER){
            self.bubbleImageView.image = UIImage(named:MBChatBubbleTableViewCell.OUTCOMING_BUBBLE)?.stretchableImageWithLeftCapWidth(15, topCapHeight: 14)
        }else{
            self.bubbleImageView.image = UIImage(named:MBChatBubbleTableViewCell.INCOMING_BUBBLE)?.stretchableImageWithLeftCapWidth(21, topCapHeight: 14)
        }
    }
    
    func setMsg(msg:String){
        
        msgLabel.text = msg
        
        let size = MBChatBubbleTableViewCell.getSizeForMsg(msg)
        
        widthConstraint.constant = (size.width) + 10
        heightConstraint.constant = (size.height)
        bubbleWidthConstraint.constant = (size.width) + 40
    }
    
    static func getSizeForMsg(msg:String)->CGSize{
        
        struct Holder {
            static var dummyLabel = UILabel(frame: CGRectZero)
        }
        
        Holder.dummyLabel.numberOfLines = 0
        
        Holder.dummyLabel.text = msg
        
        var size = Holder.dummyLabel.sizeThatFits(CGSizeMake(200, 1000))
        size = CGSizeMake(ceil(size.width), ceil(size.height)+25)
        
        return size
    }
}
