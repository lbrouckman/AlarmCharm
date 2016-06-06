//
//  SavedAlarmsTableViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Laura Brouckman


/*
 This view controller is a CoreDataTableViewController that displays the alarms that a user has previously made. They can click on the alarms
 to choose one to be their friends alarm, or continue on to create a new alarm.
 */

import UIKit
import Contacts
import CoreData

class SavedAlarmsTableViewController: CoreDataTableViewController {
    //set by previous VC
    var friendSelected: String?
    private var remoteDB = Database()
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    //Load the alarms from CoreData into the fetchedResultsController
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
    
    //Checkmark functionality lets the user see/select which alarm they have set for their friend
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
    
    //When a cell is selected, if it wasn't checked yet, then make it checked (and make all other cells unchecked) and then
    //set the selected alarm to be the friends alarm in the remote database
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
                     if let audioFilename = selected.audioFilename {
                        if let audioURL = NSURL(string: audioFilename) {
                            remoteDB.uploadFileToDatabase(audioURL, forUser: friendSelected!, fileType: "Audio")
                        }
                    }
                    if let imageFilename = selected.imageFilename {
                        if let imageURL = NSURL(string: imageFilename) {
                            remoteDB.uploadFileToDatabase(imageURL, forUser: friendSelected!, fileType: "Image")
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
    
    //The user is no longer in the process of being set at this point
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            remoteDB.userInProcessOfBeingSet(forUser: friendSelected!, inProcess: false)
        }
    }
    
    //If the view disappears for some other reason (other than back button) also toggle the inProcess for the friend
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        remoteDB.userInProcessOfBeingSet(forUser: friendSelected!, inProcess: false)
    }

    //send the next VC the managedObjectContext and what friend they're setting the alarm of
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
