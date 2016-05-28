//
//  Database.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 5/28/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import Foundation
import Firebase

class Database {
    
    
    private var usersRef = FIRDatabase.database().reference().child("users")
    
    func uploadFileToDatabase(fileURL: NSURL, forUser userID: String) {
        
        let filename = fileURL.lastPathComponent!
        let storage = FIRStorage.storage()
        let gsReference = storage.referenceForURL("gs://project-5208532535641760898.appspot.com")
        let fileRef = gsReference.child(filename)
        
        // Upload the file to the path "images/rivers.jpg"
        let _ = fileRef.putFile(fileURL, metadata: nil) { metadata, error in
            if (error != nil) {
                print(error)
            } else {
                let currUserRef = self.usersRef.child(userID)
                let newSound = ["audio_file": filename]
                currUserRef.updateChildValues(newSound)
            }
        }

    }
    
    func downloadFileToLocal(forUser userID: String) {
        //Carlisle your function will go here!
    }
    
}
