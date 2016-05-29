//
//  Alarm+CoreDataProperties.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/29/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Alarm {

    @NSManaged var imageFilename: String?
    @NSManaged var audioFilename: String?
    @NSManaged var alarmName: String?
    @NSManaged var alarmMessage: String?

}
