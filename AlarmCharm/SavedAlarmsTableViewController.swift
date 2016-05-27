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
    var contact: CNContact?
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    private func loadAlarms() {
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "Alarm")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
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
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("SavedAlarmCell", forIndexPath: indexPath)
            
            if let savedAlarm = fetchedResultsController?.objectAtIndexPath(indexPath) as? Alarm {
                var name: String?
                savedAlarm.managedObjectContext?.performBlockAndWait {
                    name = savedAlarm.name
                }
                cell.textLabel?.text = name
                if indexPath.row == checkedIndex {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
            }
            return cell
    }
    
    private var checkedIndex: Int?

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                //Set all of the other ones to unchecked
                if checkedIndex != nil {
                    for i in 0...tableView.numberOfRowsInSection(0) {
                        if let c = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) {
                            c.accessoryType = .None
                        }
                    }
                }
                cell.accessoryType = .Checkmark
                checkedIndex = indexPath.row
            }
        }    
    }
 
//send the next VC the managedObjectContext

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
