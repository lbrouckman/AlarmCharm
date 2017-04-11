//
//  LoginViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 2/22/17.
//  Copyright © 2017 Laura Brouckman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging


class LoginViewController: UIViewController {
    fileprivate var remoteDB = Database()
    
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var phoneNumberTextBox: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var phoneNumber: String?
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enterPressed(_ sender: UIButton) {
        //check if blank
        if let number = phoneNumberTextBox.text, number.characters.count > 6 {
            phoneNumber = number
        } else {
            //Error message
            errorLabel.text = "Error: Please enter a valid phone number"
            print("INVALID PHONE #")
            return
        }
        
        if let password = passwordTextBox.text {
            if password.characters.count < 5 {
                //Error message
                errorLabel.text = "Error: Password must have at least 5 characters"
                return
            }
        } else {
            errorLabel.text = "Error: Password must have at least 5 characters"
            return
        }
        
        
        remoteDB.userInDatabase(phoneNumberTextBox.text!) { user in
            if user == nil {
                //Error message
                self.errorLabel.text = "Error: No user with the given phone number found"
                return
            } else {
                if let snapshotDictionary = user as? NSDictionary {
                    if let password = snapshotDictionary["password"] as? String {
                        let passwordEntered = self.remoteDB.sha256(self.passwordTextBox.text!)
                        if passwordEntered != password {
                            //Error message
                            self.errorLabel.text = "Error: The password is incorrect"
                            return
                        } else {
                            //Enter app
                            if let name = snapshotDictionary["username"] as? String {
                                self.userName = name
                                self.performSegue(withIdentifier: "Login", sender: nil)
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Login" {
            
            Foundation.UserDefaults.standard.setValue(phoneNumber, forKey: "PhoneNumber")
            Foundation.UserDefaults.standard.setValue(userName, forKey: "Username")
            
            var tokenName = "notGivenYet"
            if let tokenString = FIRInstanceID.instanceID().token()?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                tokenName = tokenString
                print(tokenString, "is the token string")
            }
            remoteDB.updateTokenForUser(forUser: phoneNumber!, forToken: tokenName)
        }
    }
    
    
}
