//
//  FriendTableViewCell.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Laura Brouckman

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
    
    fileprivate func updateUI() {
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
                let date = Date(timeIntervalSince1970: alarmTime!)
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let timeString = formatter.string(from: date)
                contactAlarmTime?.text = timeString
            } else {
                contactAlarmTime?.text = "Not Set"
            }
        } else {
            contactAlarmTime?.text = "Not Set"
        }
    }
    
    //Set image to the be the contact image or a default "blank" image if there is no contact image
    fileprivate func setImage() {
        if contact!.imageData != nil {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak weakSelf = self] in
                let imageData = weakSelf?.contact!.imageData!
                DispatchQueue.main.async {
                    if imageData == weakSelf?.contact!.imageData! {
                        if let data = imageData {
                            weakSelf?.contactPicture?.image = UIImage(data: data)
                            weakSelf?.setNeedsLayout()
                        }
                    }
                }
            }
        } else {
            let imageURL = URL(fileURLWithPath: Bundle.main.path(forResource: "defaultImage", ofType: "jpg")!)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak weakSelf = self] in
                let contentsOfURL = try? Data(contentsOf: imageURL)
                DispatchQueue.main.async {
                    if imageURL == URL(fileURLWithPath: Bundle.main.path(forResource: "defaultImage", ofType: "jpg")!) {
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
