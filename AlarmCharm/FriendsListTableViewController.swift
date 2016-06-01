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
        var message: String?
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
                if let should_be_set = snapshot.value!["need_friend_to_set"] as? Bool {
                    if should_be_set{
                        if let getting_set = snapshot.value!["in_process_of_being_set"] as? Bool {
                            if !getting_set{
                                let message = snapshot.value!["user_message"] as? String
                                let newFriend = Friend(contact: contact, alarmTime: x, phoneNumber: userID, message: message)
                                self.friendList.append(newFriend)
                            }
                        }
                    }
                }
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
            friendCell.message = friend.message
        }
        
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ShowSavedAlarms"{
                if let cell = sender as? FriendTableViewCell, let indexPath = tableView.indexPathForCell(cell),
                    let savedvc = segue.destinationViewController as? SavedAlarmsTableViewController {
                    //We should set the user's needToBeSet to false here, as they are about to set it, and we don't want someone to record an alarm
                    // and then not be able to post it.
                    let friend = friendList[indexPath.row]
                    savedvc.friendSelected = friend.phoneNumber
                    Database.userInProcessOfBeingSet(forUser: friend.phoneNumber, inProcess: true)
                }
            }
        }
    }
    
}
