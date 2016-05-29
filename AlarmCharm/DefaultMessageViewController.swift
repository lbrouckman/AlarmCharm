//
//  DefaultMessageViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/29/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit

class DefaultMessageViewController: UIViewController, UITextFieldDelegate {
    
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
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        if let message = textField.text! as? String{
            if let userId = NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String{
                Database.uploadUserMessageToDatabase(message, forUser: userId)
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