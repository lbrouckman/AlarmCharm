//
//  SetDefaultSoundTableTableViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//

import UIKit
import AVFoundation

// This protocol is implemented by the view controller so that whend the DefaultSoundTableViewCell has a button bushed
// the view controller can act accordingly.
protocol DefaultSoundTableViewCellDelegate {
    func cellWasPressed(cell : DefaultSoundTableViewCell, button: UIButton)
}

/* This view controller lets the user choose what they want their default ring tone to be (if no one sets it for them :( ) They can play/stop/set 
 the sound from the cell. The set sound will be highlighted in red.
 */
class SetDefaultSoundTableViewController: UITableViewController, DefaultSoundTableViewCellDelegate {
    var alarmAudioPlayer : AVAudioPlayer?
    
    var softPianoAudioUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Alarm_Soothing_Piano", ofType: "wav")!)
    
    var soundFiles = ["Alarm_Soothing_Piano", "Alarm_Obnoxious_Synth", "Alarm_Soothing_Guitar", "AND_HIS_NAME_IS_JOHN_CENA"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try alarmAudioPlayer = AVAudioPlayer(contentsOfURL: softPianoAudioUrl, fileTypeHint: nil)
            tableView.allowsSelection = false
        } catch{
        }
        tableView.backgroundColor = Colors.offwhite
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        alarmAudioPlayer?.stop()
    }
    
    // Based on which button in the cell is pressed, we play,stop or set the song to be the user's default song choice.
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
                setHighlightedNonDefault(defaultCell!)
                setHighlightedDefault(cell)
                defaultCell = cell
            default: break
            }
        }
        catch{
        }
    }
    
    //This sets the UI for the cell containing the default alarm song
    private func setHighlightedDefault(cell: DefaultSoundTableViewCell){
        cell.backgroundColor = Colors.cherry
        cell.SongNameLabel.textColor = Colors.offwhite
    }
    
    //This sets the UI for cells not chosen to be the default ringtone
    private func setHighlightedNonDefault(cell: DefaultSoundTableViewCell){
        cell.backgroundColor = Colors.offwhite
        cell.SongNameLabel.textColor = Colors.plum
    }
    
    var defaultCell: DefaultSoundTableViewCell?
    //Returns the name of the song that is in NSUser defaults as the current default alarm
    
   
    //If the user's alarm has not been set already, it will change the user's alarm notification sound to be the new default ringtone
    private func setUserPreference(songName: String){
        UserDefaults.setDefaultSongName(songName)
        print(UserDefaults.hasAlarmBeenSet())
        if UserDefaults.hasAlarmBeenSet() == false {
            print("about to change notification noise")
            //If no friend has set the user's alarm, we want to set the default song to be the notification noise
                Notifications.changeDefaultSong(songName + ".wav")
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if soundFiles.count > 0 {
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundFiles.count
    }
    
    //This sets the song name for each cell and highlights the cell if it contains the default ringtone
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("SoundCell", forIndexPath: indexPath) as? DefaultSoundTableViewCell {
            let currentSongName = soundFiles[indexPath.row]
            let defaultSong = UserDefaults.getDefaultSongName()
            //This would only ever happen the very first time the user opened the app and didnt have a default song chosen
           
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
