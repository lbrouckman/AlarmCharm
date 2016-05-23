//
//  Alarm.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/22/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import Foundation
import CoreData


class Alarm: NSManagedObject {

    //add audio recording functionality
    class func addAlarmToDB(name: String, videoURL: String?, imageData: NSData?,inManagedObjectContext context: NSManagedObjectContext) -> Alarm? {
        print("Adding alarm with name \(name) to DB")
        let request = NSFetchRequest(entityName: "Alarm")
        request.predicate = NSPredicate(format: "name = %@", name)
        
        if let result = (try? context.executeFetchRequest(request))?.first as? Alarm {
            return result
        } else if let result = NSEntityDescription.insertNewObjectForEntityForName("Alarm", inManagedObjectContext: context) as? Alarm {
            result.name = name
            result.videoURL = videoURL
            result.image = imageData
            return result
        }
        return nil
    }
}
