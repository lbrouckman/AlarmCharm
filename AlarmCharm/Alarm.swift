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
    class func addAlarmToDB(name: String, alarmMessage: String?, audioFilename: String?, imageFilename: String?,inManagedObjectContext context: NSManagedObjectContext) -> Alarm? {
        print("Adding alarm with name \(name) to DB")
        let request = NSFetchRequest(entityName: "Alarm")
        request.predicate = NSPredicate(format: "alarmName = %@", name)
        
        if let result = (try? context.executeFetchRequest(request))?.first as? Alarm {
            result.imageFilename = imageFilename
            result.audioFilename = audioFilename
            result.alarmMessage = alarmMessage
            return result
        } else if let result = NSEntityDescription.insertNewObjectForEntityForName("Alarm", inManagedObjectContext: context) as? Alarm {
            result.alarmName = name
            result.audioFilename = audioFilename
            result.imageFilename = imageFilename
            result.alarmMessage = alarmMessage
            return result
        }
        return nil
    }
}
