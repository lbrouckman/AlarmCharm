//
//  FriendTableViewCell.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//

import UIKit
import Contacts

/* Custom cell for showing a user their friends */
class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAlarmTime: UILabel!
    @IBOutlet weak var contactPicture: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!

    var contact: CNContact? {
        didSet {
            updateUI()
        }
    }
    
    var alarmTime: Double? {
        didSet {
            updateUI()
        }
    }
    var message: String?{
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        contactName?.text = nil
        contactAlarmTime?.text = nil
        contactPicture?.image = nil
        
        contactName?.text = contact!.givenName + " " + contact!.familyName
        if message != nil{
            messageLabel?.text = message
        }
        
        if(contact!.isKeyAvailable("imageData")) {
            setImage()
        }
        
        if alarmTime != nil {
            if alarmTime != 0 {
                let date = NSDate(timeIntervalSince1970: alarmTime!)
                let formatter = NSDateFormatter()
                formatter.timeStyle = .ShortStyle
                let timeString = formatter.stringFromDate(date)
                contactAlarmTime?.text = timeString
            } else {
                contactAlarmTime?.text = "Not Set"
            }
        } else {
            contactAlarmTime?.text = "Not Set"
        }
    }
    
    //Set image to the be the contact image or a default "blank" image if there is no contact image
    private func setImage() {
        if contact!.imageData != nil {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
                let imageData = weakSelf?.contact!.imageData!
                dispatch_async(dispatch_get_main_queue()) {
                    if imageData == weakSelf?.contact!.imageData! {
                        if let data = imageData {
                            weakSelf?.contactPicture?.image = UIImage(data: data)
                            weakSelf?.setNeedsLayout()
                        }
                    }
                }
            }
        } else {
            let imageURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("defaultImage", ofType: "jpg")!)
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
                let contentsOfURL = NSData(contentsOfURL: imageURL)
                dispatch_async(dispatch_get_main_queue()) {
                    if imageURL == NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("defaultImage", ofType: "jpg")!) {
                        if let imageData = contentsOfURL {
                            weakSelf?.contactPicture?.image = UIImage(data: imageData)
                            weakSelf?.setNeedsDisplay()
                        }
                    }
                }
            }
        }
    }
}
