//
//  SetDefaultSoundTableTableViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import AVFoundation

protocol DefaultSoundTableViewCellDelegate {
    func cellWasPressed(cell : DefaultSoundTableViewCell, button: UIButton)
}


class SetDefaultSoundTableViewController: UITableViewController, DefaultSoundTableViewCellDelegate {
    var alarmAudioPlayer : AVAudioPlayer?
    
    var softPianoAudioUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Alarm_Soothing_Piano", ofType: "wav")!)
    
    var soundFiles = ["Alarm_Soothing_Piano", "Alarm_Obnoxious_Synth", "Alarm_Soothing_Guitar"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try alarmAudioPlayer = AVAudioPlayer(contentsOfURL: softPianoAudioUrl, fileTypeHint: nil)
            tableView.allowsSelection = false
        } catch{
        }
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        alarmAudioPlayer?.stop()
    }
    func cellWasPressed(cell : DefaultSoundTableViewCell, button: UIButton){
        let songName = cell.SongNameLabel!.text!
        let songUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(songName, ofType: "wav")!)
        do{
            try alarmAudioPlayer = AVAudioPlayer(contentsOfURL: songUrl, fileTypeHint: nil)
            switch button.titleLabel!.text!{
            case "Play":
                alarmAudioPlayer?.play()
            case "Stop":
                alarmAudioPlayer?.pause()
            case "Set":
                setUserPreference(songName)
                setHighlightedDefault(cell)
                setHighlightedNonDefault(defaultCell!)
                defaultCell = cell
            default: break
            }
        }
        catch{
        }
    }
    private func setHighlightedDefault(cell: DefaultSoundTableViewCell){
        cell.backgroundColor = UIColor.cyanColor()
    }
    private func setHighlightedNonDefault(cell: DefaultSoundTableViewCell){
        cell.backgroundColor = UIColor.whiteColor()
    }
    var defaultCell: DefaultSoundTableViewCell?
    //Returns the name of the song that is in NSUser defaults as the current default alarm
    
    private func getUserPreference() ->String? {
        let defaultSongDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_DEFAULT) ?? Dictionary()
        return defaultSongDict[Constants.USER_KEY_TO_GET_SONG_DEFAULT] as? String
    }
    
    
    private func setUserPreference(songName: String){
        var defaultSongDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_DEFAULT) ?? Dictionary()
        defaultSongDict [Constants.USER_KEY_TO_GET_SONG_DEFAULT] = songName
        
        NSUserDefaults.standardUserDefaults().setObject(defaultSongDict, forKey: Constants.USER_ALARM_DEFAULT)
        
        //If their alarm is already set, this will change the sound to be the new default
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if let oldNotification = notifications?[0]
        {
            oldNotification.soundName = songName + ".wav"
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            UIApplication.sharedApplication().scheduleLocalNotification(oldNotification)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if soundFiles.count > 0 {
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundFiles.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("SoundCell", forIndexPath: indexPath) as? DefaultSoundTableViewCell {
            let currentSongName = soundFiles[indexPath.row]
            var defaultSong = getUserPreference()
            //This would only ever happen the very first time the user opened the app and didnt have a default song chosen
            if defaultSong == nil{
                setUserPreference(currentSongName)
                defaultSong = currentSongName
            }
            // If the cell is the current default we highlight it
            if defaultSong == currentSongName {
                defaultCell = cell
                setHighlightedDefault(cell)
            }
                //Otherwise we keep its background vlank
            else{
                setHighlightedNonDefault(cell)
            }
            
            cell.delegate = self
            cell.SongNameLabel.text = currentSongName
            return cell
        }
        return tableView.dequeueReusableCellWithIdentifier("SoundCell", forIndexPath: indexPath)
    }
    
}
