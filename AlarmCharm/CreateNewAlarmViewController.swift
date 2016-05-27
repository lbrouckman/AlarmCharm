//
//  CreateAlarmViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/22/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseStorage
import AVFoundation

class CreateNewAlarmViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext?
    
    
    var player : AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDatabase( "TEST1", videoURL: nil, imageData: nil)
        //If the user's alarm sound has been set in the database, use this sound instead of the local one
        
    }
    
    
    //Should also take in the audio recording
    private func updateDatabase(alarmName: String, videoURL: String?, imageData: NSData?) {
        managedObjectContext?.performBlock { [weak weakSelf = self] in
            let _ = Alarm.addAlarmToDB(
                alarmName,
                videoURL: videoURL,
                imageData: imageData,
                inManagedObjectContext: (weakSelf?.managedObjectContext)!
            )
            do {
                try (weakSelf?.managedObjectContext)!.save()
            } catch let error {
                print(error)
            }
        }
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
