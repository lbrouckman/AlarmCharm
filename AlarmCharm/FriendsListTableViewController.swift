////
////  FriendsListTableViewController.swift
////  AlarmCharm
////
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Both
import UIKit
import Contacts
import FirebaseDatabase
import Firebase

/* This table holds all of the friends of the current user. The friends are the intersection of the persons contacts and the people in the remote database
 The friends are divided into 3 sections - if they need their alarm to be set, if someone else is already setting it, or if their alarm is done being set.
 */

class FriendsListTableViewController: UITableViewController {
    
    fileprivate var contactListFriends = [CNContact]()
    fileprivate var remoteDB = Database()
    
    fileprivate var friendList = [[Friend]]()
    
    fileprivate enum FriendStatus : Int {
        case needsToBeSet = 0
        case inProgress   = 1
        case alreadySet   = 2
    }
    
    fileprivate struct Friend {
        var contact: CNContact
        var alarmTime: Double?
        var phoneNumber: String
        var message: String?
        var status: FriendStatus
        var setBy: String?
    }
    
    fileprivate var sectionTitles = [0: "Needs to be charmed", 1 : "Being charmed now", 2: "Already been charmed" ]
    
    //http://www.appcoda.com/ios-contacts-framework/ and http://code.tutsplus.com/tutorials/ios-9-an-introduction-to-the-contacts-framework--cms-25599
    //were used as guidance on how to use ContactsKit
    fileprivate func getContacts() {
        let store = CNContactStore()
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts) { (authorized: Bool, error: Error?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store)
                    self.editContactsList()
                }
                }
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store)
            editContactsList()
        }
    }
    
    fileprivate func retrieveContactsWithStore(_ store: CNContactStore) {
        do {
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactImageDataKey] as [Any]
            let containerId = CNContactStore().defaultContainerIdentifier()
            let predicate: NSPredicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
            let contacts = try CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            self.contactListFriends = contacts
        } catch {
            print(error)
        }
    }
    
    //Phone numbers come out of CNContacts in many different formats. Here, we extract the 10 digit phone number from whatever format the number
    //came in. Note: right now, this app will only function perfectly for American phone numbers.
    fileprivate func extractNumber(_ phoneNumber: String) -> String {
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
    fileprivate func editContactsList() {
        var count = 0
        let numRealContacts = getNumActualContacts()
        for contact in contactListFriends {
            if(contact.phoneNumbers.count > 0) {
                count += 1
                let a = contact.phoneNumbers[0].value
                let num = extractNumber(a.stringValue)
                addContactToTable(num, contact: contact, numLeft: numRealContacts - count)
            }
        }
        self.tableView?.reloadData()
    }
    
    fileprivate func getNumActualContacts() -> Int {
        var total = 0
        for contact in contactListFriends {
            if(contact.phoneNumbers.count > 0) {
                total += 1
            }
        }
        return total
    }
    
    //Adds contact to database if they are in the database, puts into a section based on information from database
    //Adds it to the correct row in the 2d Friends array, and calls reloadData to keep the tableView up to date
    fileprivate func addContactToTable(_ userID: String, contact: CNContact, numLeft: Int) {
        //Don't add yourself to the list
        if userID == Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String {
            if numLeft == 0 { self.tableView?.reloadData() }
            return
        }
        let ref = FIRDatabase.database().reference()
        let hashedID = remoteDB.sha256(userID)!
        ref.child("users").child(hashedID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotDictionary = snapshot.value as? NSDictionary{
                if let x = snapshotDictionary["alarm_time"] as? Double , x != 0 {
                    if self.friendList.count == 0{
                        self.friendList.append([Friend]())
                        self.friendList.append([Friend]())
                        self.friendList.append([Friend]())
                    }
                    var friendStatus: FriendStatus
                    let should_be_set = snapshotDictionary["need_friend_to_set"] as? Bool
                    let getting_set = snapshotDictionary["in_process_of_being_set"] as? Bool
                    var setBy: String? = nil
                    if getting_set!{
                        friendStatus = FriendStatus.inProgress
                    } else if !should_be_set! {
                        friendStatus = FriendStatus.alreadySet
                        setBy = snapshotDictionary["friend_who_set_alarm"] as? String
                    } else {
                        friendStatus = FriendStatus.needsToBeSet
                    }
                    
                    let message = snapshotDictionary["user_message"] as? String
                    let newFriend = Friend(contact: contact, alarmTime: x, phoneNumber: userID, message: message, status: friendStatus, setBy: setBy)
                    let sectionNumber = friendStatus.rawValue
                    self.friendList[sectionNumber].append(newFriend)
                }
            }
            if numLeft == 0 { self.tableView?.reloadData() }
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friendList.removeAll() // Maybe throwing a bug here?
        getContacts()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Should be 3
        return friendList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList[section].count
    }
    
    //Populates a FriendCell with the correct information
    fileprivate func fillCell(_ cell: UITableViewCell, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let friend = friendList[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        if let friendCell = cell as? FriendTableViewCell {
            friendCell.contact = friend.contact
            friendCell.alarmTime = friend.alarmTime
            if (indexPath as NSIndexPath).section == 2 {
                friendCell.message = "Set by: " + friend.setBy!
            } else {
                friendCell.message = friend.message
            }
            return friendCell
        }
        return cell
    }
    
    //Switch on the section the cell is in to dequeue the correct type of cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch (indexPath as NSIndexPath).section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "AvailableFriendCell", for: indexPath)
            cell = fillCell(cell, forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "InProgressFriendCell", for: indexPath)
            cell = fillCell(cell, forIndexPath: indexPath)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "AlreadySetFriendCell", for: indexPath)
            cell = fillCell(cell, forIndexPath: indexPath)
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Colors.plum
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Colors.offwhite
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ShowSavedAlarms"{
                if let cell = sender as? FriendTableViewCell, let indexPath = tableView.indexPath(for: cell),
                    let savedvc = segue.destination as? SavedAlarmsTableViewController {
                    let friend = friendList[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                    savedvc.friendSelected = friend.phoneNumber
                    remoteDB.userInProcessOfBeingSet(forUser: friend.phoneNumber, inProcess: true)
                }
            }
        }
    }
    
}
