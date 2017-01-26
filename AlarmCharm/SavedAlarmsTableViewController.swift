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
    fileprivate var remoteDB = Database()
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    //Load the alarms from CoreData into the fetchedResultsController
    fileprivate func loadAlarms() {
        if let context = managedObjectContext {
            let request:  NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Alarm")
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedAlarmCell", for: indexPath)
        
        if let savedAlarm = fetchedResultsController?.object(at: indexPath) as? Alarm {
            var name: String?
            savedAlarm.managedObjectContext?.performAndWait {
                name = savedAlarm.alarmName
            }
            cell.textLabel?.text = name
            if (indexPath as NSIndexPath).row == checkedIndex {
                cell.detailTextLabel?.text = "✓"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        return cell
    }
    
    fileprivate var checkedIndex: Int?
    
    //When a cell is selected, if it wasn't checked yet, then make it checked (and make all other cells unchecked) and then
    //set the selected alarm to be the friends alarm in the remote database
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.detailTextLabel?.text == "" {
                //Set all of the other ones to unchecked
                if checkedIndex != nil {
                    for i in 0...tableView.numberOfRows(inSection: 0) {
                        if let c = tableView.cellForRow(at: IndexPath(row: i, section: 0)) {
                            c.detailTextLabel?.text = ""
                        }
                    }
                }
                let selectedAlarm = fetchedResultsController?.fetchedObjects?[(indexPath as NSIndexPath).row] as? Alarm
                if let selected = selectedAlarm {
                    //Let's allow other people to keep charming until accepted.
//                    remoteDB.userNeedsAlarmToBeSet(forUser: friendSelected!, toBeSet: false)
                    if let username = Foundation.UserDefaults.standard.value(forKey: "Username") as? String{
                        remoteDB.changeWhoSetAlarm(username, forUser: friendSelected!)
                        remoteDB.addNotification(forUser: friendSelected!, setBy: username)
                    }
                     if let audioFilename = selected.audioFilename {
                        if let audioURL = URL(string: audioFilename) {
                            remoteDB.uploadFileToDatabase(audioURL, forUser: friendSelected!, fileType: "Audio")
                        }
                    }
                    if let imageFilename = selected.imageFilename {
                        if let imageURL = URL(string: imageFilename) {
                            remoteDB.uploadFileToDatabase(imageURL, forUser: friendSelected!, fileType: "Image")
                        }
                    }
                    if let message = selected.alarmMessage {
                        remoteDB.uploadWakeUpMessageToDatabase(message, forUser: friendSelected!)
                    }
                }
                cell.detailTextLabel?.text = "✓"
                checkedIndex = (indexPath as NSIndexPath).row
            }
        }
    }
    
    //The user is no longer in the process of being set at this point
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
//            remoteDB.userInProcessOfBeingSet(forUser: friendSelected!, inProcess: false)
        }
    }
    
    //If the view disappears for some other reason (other than back button) also toggle the inProcess for the friend
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        remoteDB.userInProcessOfBeingSet(forUser: friendSelected!, inProcess: false)
    }

    //send the next VC the managedObjectContext and what friend they're setting the alarm of
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "CreateNewAlarm"{
                if let createvc = segue.destination as? CreateNewAlarmViewController {
                    createvc.userID = friendSelected
                    createvc.managedObjectContext = managedObjectContext
                }
            }
        }
    }
}
