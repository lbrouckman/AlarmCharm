//
//  DefaultMessageViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/29/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Laura Brouckman

import UIKit

/* Basic view controller that lets the user set what message they wnat other users to see as their message.
 */
class DefaultMessageViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate var remoteDB = Database()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var messageTextField: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        if let message = textField.text {
            if let userId = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String{
                remoteDB.uploadUserMessageToDatabase(message, forUser: userId)
                Foundation.UserDefaults.standard.setValue(message, forKey: "User Default Message")
            }
            
        }
        return true
    }
}
