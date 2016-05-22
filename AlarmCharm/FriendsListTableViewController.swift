//
//  FriendsListTableViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/22/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import Contacts

class FriendsListTableViewController: UITableViewController {

    var objects = [CNContact]()
    
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatusForEntityType(.Contacts) == .NotDetermined {
            store.requestAccessForEntityType(.Contacts) { (authorized: Bool, error: NSError?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store)
                }
            }
        } else if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized {
            self.retrieveContactsWithStore(store)
        }
    }
    
    
    func retrieveContactsWithStore(store: CNContactStore) {
        do {
            let groups = try store.groupsMatchingPredicate(nil)
            let predicate = CNContact.predicateForContactsInGroupWithIdentifier(groups[0].identifier)
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey, CNContactImageDataKey]
            
            let contacts = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            self.objects = contacts
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        } catch {
            print(error)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
    }

    
    func insertNewObject(sender: NSNotification) {
        if let contact = sender.userInfo?["contactToAdd"] as? CNContact {
            objects.insert(contact, atIndex: 0)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath)
        
        let contact = objects[indexPath.row]
        if let friendCell = cell as? FriendTableViewCell {
            friendCell.contact = contact
        }
        
        return cell
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
