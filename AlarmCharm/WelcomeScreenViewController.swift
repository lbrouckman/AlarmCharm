//
//  WelcomeScreenViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/24/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Laura Brouckman

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging

/* Home screen when the user first enters the app. It asks for their phone number (to be able to connect them with their friends from contacts) and a username
 Ensures that the user's phone number is not already in the database. Adds the user to the database under a hash of their phonenumber
 Only appears the first time a user opens the the app.
 */
class WelcomeScreenViewController: UIViewController {
    
    fileprivate var remoteDB = Database()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let launchedBefore = Foundation.UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            self.performSegue(withIdentifier: "ShowMain", sender: self)
        } else {
            Foundation.UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
     
    @IBOutlet weak var usernameTextBox: UITextField!
    @IBOutlet weak var textBox: UITextField!
    fileprivate var ref = FIRDatabaseReference.init()
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBAction func enterButtonPressed() {
        if let username = usernameTextBox.text {
            if username.characters.count < 5 {
                errorLabel.text = "Error: Usernames must be at least 5 characters"
                return
            }
        }
        if let phonenumber = textBox.text {
            if phonenumber.characters.count != 10 {
                errorLabel.text = "Error: Please enter a valid phone number"
                return
            }
            remoteDB.userInDatabase(phonenumber) { alreadyInDB in
                if alreadyInDB {
                    print(phonenumber)
                    print(alreadyInDB)
                    self.performSegue(withIdentifier: "StorePhoneNumber", sender: nil)

                    self.errorLabel.text = "Error: Phone number has already been used"
                } else {
                    self.performSegue(withIdentifier: "StorePhoneNumber", sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StorePhoneNumber" {
            let phoneNumber = textBox.text!
            let username = usernameTextBox.text!
            
            // Remember to update token if token changes...
            Foundation.UserDefaults.standard.setValue(phoneNumber, forKey: "PhoneNumber")
            Foundation.UserDefaults.standard.setValue(username, forKey: "Username")
            
            let tokenString = FIRInstanceID.instanceID().token()?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            print(tokenString, "is the token string")
            remoteDB.addNewUserToDB(phoneNumber, username: username, token:tokenString!)
        }
    }
}
