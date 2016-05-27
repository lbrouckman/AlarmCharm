//
//  WelcomeScreenViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/24/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class WelcomeScreenViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if launchedBefore  {
            self.performSegueWithIdentifier("ShowMain", sender: self)
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        }
    }
    

    @IBOutlet weak var textBox: UITextField!
    private var ref = FIRDatabaseReference.init()

    //If the user doesn't enter a phone number this will crash
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StorePhoneNumber" {
            let phoneNumber = textBox.text!
            NSUserDefaults.standardUserDefaults().setValue(phoneNumber, forKey: "PhoneNumber")
            ref = FIRDatabase.database().reference()
            let usersRef = ref.child("users");
            let newUser = ["alarm_time": 0, "image_file": "", "audio_file": ""]
            let newUserRef = usersRef.child(phoneNumber)
            newUserRef.setValue(newUser)
        }
    }
}
