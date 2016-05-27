//
//  FriendTableViewCell.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/22/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import Contacts

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAlarmTime: UILabel!
    @IBOutlet weak var contactPicture: UIImageView!
    
    private struct Friend {
        var name: String?
        var phoneNumber: String?
        var imageData: NSData?
    }
    
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
    
    var phoneNumber: String?
    
    private func updateUI() {
        contactName?.text = nil
        contactAlarmTime?.text = nil
        contactPicture?.image = nil
        
        contactName?.text = contact!.givenName + " " + contact!.familyName
        
        //maybe have a default image to set this to
        if(contact!.isKeyAvailable("imageData")) {
            setImage()
        }
        if alarmTime != nil {
            let date = NSDate(timeIntervalSince1970: alarmTime!)
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            let timeString = formatter.stringFromDate(date)
            contactAlarmTime?.text = timeString
        } else {
            contactAlarmTime?.text = "Not Set"
        }
    }
    
    private func setImage() {
        if contact!.imageData != nil {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
                let imageData = weakSelf?.contact!.imageData!
                dispatch_async(dispatch_get_main_queue()) {
                    if imageData == weakSelf?.contact!.imageData! {
                        if let data = imageData {
                            weakSelf?.contactPicture?.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
    
}
