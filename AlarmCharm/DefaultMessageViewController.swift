//
//  DefaultMessageViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/29/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit

class DefaultMessageViewController: UIViewController, UITextFieldDelegate {
    
    private var remoteDB = Database()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        print(NSUserDefaults.standardUserDefaults().valueForKey("test") as? String)
        WelcomeScreenViewController.fetch{
        print("fetch returned")
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var messageTextField: UITextField!
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        if let message = textField.text {
            if let userId = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String{
                remoteDB.uploadUserMessageToDatabase(message, forUser: userId)
                NSUserDefaults.standardUserDefaults().setValue(message, forKey: "User Default Message")
            }
            
        }
        return true
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
