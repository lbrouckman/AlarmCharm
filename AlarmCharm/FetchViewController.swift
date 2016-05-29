//
//  FetchViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/29/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//
import UIKit

class FetchViewController: UIViewController {

    var remoteDB = Database()
    
    func fetch(completion: () -> Void) {
        if let user = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            remoteDB.downloadFileToLocal(forUser: user)
            //download image as well
            //Set the wake up message in user defaults
            //NSUserDefaults.standardUserDefaults().setValue(Database.getWakeUpMessage(), forKey: "WakeupMessage")
        }
        completion()
    }
}
