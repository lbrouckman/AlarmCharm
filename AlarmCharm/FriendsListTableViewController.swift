////
////  FriendsListTableViewController.swift
////  AlarmCharm
////
////  Created by Elizabeth Brouckman on 5/22/16.
////  Copyright © 2016 Laura Brouckman. All rights reserved.
////
//
import UIKit
import Contacts
import Firebase

class FriendsListTableViewController: UITableViewController {

    private var objects = [CNContact]()
    
    private var friendList = [Friend]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private struct Friend {
        var contact: CNContact
        var alarmTime: Double?
        var phoneNumber: String
    }

    private func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatusForEntityType(.Contacts) == .NotDetermined {
            store.requestAccessForEntityType(.Contacts) { (authorized: Bool, error: NSError?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store)
                    self.editContactsList()
                }
            }
        } else if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized {
            self.retrieveContactsWithStore(store)
            editContactsList()
        }
    }

    private func extractNumber(phoneNumber: String) -> String {
        var num = ""
        for character in phoneNumber.characters {
            let value = Int(String(character))
            if value != nil {
                num.append(character)
            }
        }
        if num[num.startIndex] == "1" {
            num = String(num.characters.dropFirst())
        }
        return num
    }
    
    //Functional as long as person is from the US
    private func editContactsList() {
        for contact in objects {
            if(contact.phoneNumbers.count > 0) {
                let a = contact.phoneNumbers[0].value as! CNPhoneNumber
                let num = extractNumber(a.stringValue)
                checkIfUserExists(num, contact: contact)
            }
            
        }
    }

    //EDIT SO THAT YOU DON'T ADD YOURSELF TO THE LIST
    private func checkIfUserExists(userID: String, contact: CNContact) {
        if userID == NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            return
        }
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let x = snapshot.value!["alarm_time"] as? Double {
                    let newFriend = Friend(contact: contact, alarmTime: x, phoneNumber: userID)
                    self.friendList.append(newFriend)
            }
        }) { (error) in
            print(error)
        }
    }
    
    private func retrieveContactsWithStore(store: CNContactStore) {
        do {
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey, CNContactImageDataKey]
            let containerId = CNContactStore().defaultContainerIdentifier()
            let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
            let contacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            self.objects = contacts
        } catch {
            print(error)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
    }
    
//
//    // MARK: - Table view data source
//    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath)
        
        let friend = friendList[indexPath.row]
        if let friendCell = cell as? FriendTableViewCell {
            friendCell.contact = friend.contact
            friendCell.alarmTime = friend.alarmTime
            friendCell.phoneNumber = friend.phoneNumber
        }
        
        return cell
    }
//
//    /*
//     // MARK: - Navigation
//     
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//    
}
