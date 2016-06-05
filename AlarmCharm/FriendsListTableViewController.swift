////
////  FriendsListTableViewController.swift
////  AlarmCharm
////
////  Created by Elizabeth Brouckman on 5/22/16.
////  Copyright © 2016 Laura Brouckman. All rights reserved.
//// Right now it is kind of spazzy i think because friendlist gets changed a lot each time it gets appended and it keeps reloading the tableView
//
import UIKit
import Contacts
import Firebase

class FriendsListTableViewController: UITableViewController {
    
    private var objects = [CNContact]()
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
    }
    
    private var sectionTitles = [0: "Needs to be charmed", 1 : "Being charmed now", 2: "Already been charmed" ]
    
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
        for i in 0..<objects.count {
            let contact = objects[i]
            if(contact.phoneNumbers.count > 0) {
                let a = contact.phoneNumbers[0].value as! CNPhoneNumber
                let num = extractNumber(a.stringValue)
                if i == objects.count - 1 {
                    addContactToTable(num, contact: contact, shouldReloadData: true)
                } else {
                    addContactToTable(num, contact: contact, shouldReloadData: false)
                }
            }
        }
    }
    
    private func addContactToTable(userID: String, contact: CNContact, shouldReloadData: Bool) {
        //Don't add yourself to the list
        if userID == NSUserDefaults.standardUserDefaults().valueForKey("PhoneNumber") as? String {
            return
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let x = snapshot.value!["alarm_time"] as? Double {
                if self.friendList.count == 0 {
                    self.friendList.append([Friend]())
                    self.friendList.append([Friend]())
                    self.friendList.append([Friend]())
                }
                
                var friendStatus: FriendStatus
                let should_be_set = snapshot.value!["need_friend_to_set"] as? Bool
                let getting_set = snapshot.value!["in_process_of_being_set"] as? Bool
                
                if should_be_set! && getting_set!{
                    friendStatus = FriendStatus.InProgress
                } else if !should_be_set! {
                    friendStatus = FriendStatus.AlreadySet
                } else {
                    friendStatus = FriendStatus.NeedsToBeSet
                }
                
                let message = snapshot.value!["user_message"] as? String
                let newFriend = Friend(contact: contact, alarmTime: x, phoneNumber: userID, message: message, status: friendStatus)
                let sectionNumber = friendStatus.rawValue
                self.friendList[sectionNumber].append(newFriend)
                
                self.tableView?.reloadData()
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
        self.navigationController?.navigationBar.barTintColor = Colors.offyellow
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.plum]
        self.navigationController?.navigationBar.tintColor = Colors.plum
        tableView.backgroundColor = Colors.offwhite
    }
    
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
        // #warning Incomplete implementation, return the number of rows
        return friendList[section].count
    }
    
    private func fillCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friend = friendList[indexPath.section][indexPath.row]
        if let friendCell = cell as? FriendTableViewCell {
            friendCell.contact = friend.contact
            friendCell.alarmTime = friend.alarmTime
            friendCell.phoneNumber = friend.phoneNumber
            friendCell.message = friend.message
            return friendCell
        }
        return cell
    }
    
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
                    //We should set the user's needToBeSet to false here, as they are about to set it, and we don't want someone to record an alarm
                    //  and then not be able to post it.
                    let friend = friendList[indexPath.section][indexPath.row]
                    savedvc.friendSelected = friend.phoneNumber
                    remoteDB.userInProcessOfBeingSet(forUser: friend.phoneNumber, inProcess: true)
                    
                }
            }
        }
    }
    
}
