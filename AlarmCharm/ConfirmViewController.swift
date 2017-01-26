//
//  ConfirmViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 1/25/17.
//  Copyright © 2017 Laura Brouckman. All rights reserved.
//

import UIKit

class ConfirmViewController: UIViewController {
    
    @IBOutlet weak var goHomeButton: UIButton!
    public var charmer : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.cherry
        confirmButton.setTitleColor(Colors.offwhite, for: UIControlState.normal)
         confirmButton.alpha = 0.5
         goHomeButton.setTitleColor(Colors.offwhite, for: UIControlState.normal)
        if charmer != nil{
            let buttonTitle = "Accept " + charmer! + " alarm?"
            confirmButton.setTitle(buttonTitle, for: UIControlState.normal)
        }
        else {
            confirmButton.setTitle("Accept friends alarm?", for: UIControlState.normal)
        }
    }

        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var confirmButton: UIButton!


    @IBAction func confirmCharm(_ sender: Any) {
        confirmButton.isEnabled = false
        confirmButton.alpha = 1.0
        confirmButton.setTitle("Accepted ✓", for: UIControlState.disabled)
        //Fetch first??
        Notifications.setNotificationFromFileSystem()
        UserDefaults.setState(State.confirmedFriendHasSetAlarm)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
