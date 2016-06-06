////
////  FriendsListTableViewController.swift
////  AlarmCharm
////
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
import UIKit
import Contacts
import Firebase

/* This table holds all of the friends of the current user. The friends are the intersection of the persons contacts and the people in the remote database
 The friends are divided into 3 sections - if they need their alarm to be set, if someone else is already setting it, or if their alarm is done being set.
 */

class FriendsListTableViewController: UITableViewController {
    
    private var contactListFriends = [CNContact]()
    private var remoteDB = Database()
    
    private var friendList = [[Friend]]()
    
    private enum FriendStatus : Int {
        case NeedsToBeSet = 0
        case InProgress   = 1
        case AlreadySet   = 2
    }
    
    private struct Friend {
        var contact: CNContact
        var alarmTime: Double?
        var phoneNumber: String
        var message: String?
        var status: FriendStatus
        var setBy: String?
    }
    
    private var sectionTitles = [0: "Needs to be charmed", 1 : "Being charmed now", 2: "Already been charmed" ]
    
    //http://www.appcoda.com/ios-contacts-framework/ and http://code.tutsplus.com/tutorials/ios-9-an-introduction-to-the-contacts-framework--cms-25599
    //were used as guidance on how to use ContactsKit
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
    
    private func retrieveContactsWithStore(store: CNContactStore) {
        do {
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey, CNContactImageDataKey]
            let containerId = CNContactStore().defaultContainerIdentifier()
            let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
            let contacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            self.contactListFriends = contacts
        } catch {
            print(error)
        }
    }
    
    //Phone numbers come out of CNContacts in many different formats. Here, we extract the 10 digit phone number from whatever format the number
    //came in. Note: right now, this app will only function perfectly for American phone numbers.
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
    
    //Edit contacts list puts the phone number into the correct format, call addContactToTable which adds the contact if they are in the database
    private func editContactsList() {
        for contact in contactListFriends {
            if(contact.phoneNumbers.count > 0) {
                let a = contact.phoneNumbers[0].value as! CNPhoneNumber
                let num = extractNumber(a.stringValue)
                addContactToTable(num, contact: contact)
            }
        }
    }
    
    //Adds contact to database if they are in the database, puts into a section based on information from database
    //Adds it to the correct row in the 2d Friends array, and calls reloadData to keep the tableView up to date
    private func addContactToTable(userID: String, contact: CNContact) {
        //Don't add yourself to the list
        if userID == NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let hashedID = remoteDB.sha256(userID)!
        ref.child("users").child(hashedID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let x = snapshot.value!["alarm_time"] as? Double {
                if self.friendList.count == 0 {
                    self.friendList.append([Friend]())
                    self.friendList.append([Friend]())
                    self.friendList.append([Friend]())
                }
                
                var friendStatus: FriendStatus
                let should_be_set = snapshot.value!["need_friend_to_set"] as? Bool
                let getting_set = snapshot.value!["in_process_of_being_set"] as? Bool
                var setBy: String? = nil
                if should_be_set! && getting_set!{
                    friendStatus = FriendStatus.InProgress
                } else if !should_be_set! {
                    friendStatus = FriendStatus.AlreadySet
                    setBy = snapshot.value!["friend_who_set_alarm"] as? String
                } else {
                    friendStatus = FriendStatus.NeedsToBeSet
                }
                
                let message = snapshot.value!["user_message"] as? String
                let newFriend = Friend(contact: contact, alarmTime: x, phoneNumber: userID, message: message, status: friendStatus, setBy: setBy)
                let sectionNumber = friendStatus.rawValue
                self.friendList[sectionNumber].append(newFriend)
                
                self.tableView?.reloadData()
            }
        }) { (error) in
            print(error)
        }
    }
    
    //Navigation Controller styling (since this is a root controller)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = Colors.offyellow
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.plum]
        self.navigationController?.navigationBar.tintColor = Colors.plum
        tableView.backgroundColor = Colors.offwhite
    }
    
    //Clear out the friendsList to avoid duplicates, load in all the data
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        friendList.removeAll()
        getContacts()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Should be 3
        return friendList.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList[section].count
    }
    
    //Populates a FriendCell with the correct information
    private func fillCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friend = friendList[indexPath.section][indexPath.row]
        if let friendCell = cell as? FriendTableViewCell {
            friendCell.contact = friend.contact
            friendCell.alarmTime = friend.alarmTime
            if indexPath.section == 2 {
                friendCell.message = "Set by: " + friend.setBy!
            } else {
                friendCell.message = friend.message
            }
            return friendCell
        }
        return cell
    }
    
    //Switch on the section the cell is in to dequeue the correct type of cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("AvailableFriendCell", forIndexPath: indexPath)
            cell = fillCell(cell, forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("InProgressFriendCell", forIndexPath: indexPath)
            cell = fillCell(cell, forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("AlreadySetFriendCell", forIndexPath: indexPath)
            cell = fillCell(cell, forIndexPath: indexPath)
        default:
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Colors.plum
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Colors.offwhite
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ShowSavedAlarms"{
                if let cell = sender as? FriendTableViewCell, let indexPath = tableView.indexPathForCell(cell),
                    let savedvc = segue.destinationViewController as? SavedAlarmsTableViewController {
                   let friend = friendList[indexPath.section][indexPath.row]
                    savedvc.friendSelected = friend.phoneNumber
                    remoteDB.userInProcessOfBeingSet(forUser: friend.phoneNumber, inProcess: true)
                }
            }
        }
    }
    
}
