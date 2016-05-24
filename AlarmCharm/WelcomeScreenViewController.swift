//
//  WelcomeScreenViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/24/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit

class WelcomeScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        }
        else {
            print("First launch, setting NSUserDefault.")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
            self.performSegueWithIdentifier("ShowMain", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("SEGUE")
        if segue.identifier == "ShowMain" {
            print("should segue")
        }
    }
}
