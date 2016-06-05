//
//  SavedAlarmsTableViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/22/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//


/*
 TO DO:
 should have a model that contains the saved alarms and the contact that was clicked to ge to here (prepare for segue of friendsTableViewController
 check marks = only one or zero allowed, the one that is checked is the alarm that has been chosen for that friend (maybe have a None option?)
 display the names (decided by the user) of the saved alarms that they've created in the past
 */

import UIKit
import Contacts
import CoreData

class SavedAlarmsTableViewController: CoreDataTableViewController {
    //set by previous VC
    var friendSelected: String?
    var remoteDB = Database()
    
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    private func loadAlarms() {
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "Alarm")
            request.sortDescriptors = [NSSortDescriptor(key: "alarmName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        } else {
            fetchedResultsController = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAlarms()
        tableView.backgroundColor = Colors.offwhite
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SavedAlarmCell", forIndexPath: indexPath)
        
        if let savedAlarm = fetchedResultsController?.objectAtIndexPath(indexPath) as? Alarm {
            var name: String?
            savedAlarm.managedObjectContext?.performBlockAndWait {
                name = savedAlarm.alarmName
            }
            cell.textLabel?.text = name
            if indexPath.row == checkedIndex {
                cell.detailTextLabel?.text = "✓"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        return cell
    }
    
    private var checkedIndex: Int?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.detailTextLabel?.text == "" {
                //Set all of the other ones to unchecked
                if checkedIndex != nil {
                    for i in 0...tableView.numberOfRowsInSection(0) {
                        if let c = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) {
                            c.detailTextLabel?.text = ""
                        }
                    }
                }
                let selectedAlarm = fetchedResultsController?.fetchedObjects?[indexPath.row] as? Alarm
                if let selected = selectedAlarm {
                    remoteDB.userNeedsAlarmToBeSet(forUser: friendSelected!, toBeSet: false)
                    if let username = NSUserDefaults.standardUserDefaults().valueForKey("Username") as? String{
                        remoteDB.changeWhoSetAlarm(username, forUser: friendSelected!)
                    }
                     if let filename = selected.audioFilename {
                        if let url = NSURL(string: filename) {
                            remoteDB.uploadFileToDatabase(url, forUser: friendSelected!)
                        }
                    }
                    if let message = selected.alarmMessage {
                        remoteDB.uploadWakeUpMessageToDatabase(message, forUser: friendSelected!)
                    }
                }
                cell.detailTextLabel?.text = "✓"
                checkedIndex = indexPath.row
            }
        }
    }
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            remoteDB.userInProcessOfBeingSet(forUser: friendSelected!, inProcess: false)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        remoteDB.userInProcessOfBeingSet(forUser: friendSelected!, inProcess: false)
    }

    //send the next VC the managedObjectContext
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "CreateNewAlarm"{
                if let createvc = segue.destinationViewController as? CreateNewAlarmViewController {
                    createvc.userID = friendSelected
                    createvc.managedObjectContext = managedObjectContext
                }
            }
        }
    }
}
