//
//  SetDefaultSoundTableTableViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Alexander Carlisle

import UIKit
import AVFoundation

// This protocol is implemented by the view controller so that whend the DefaultSoundTableViewCell has a button bushed
// the view controller can act accordingly.
protocol DefaultSoundTableViewCellDelegate {
    func cellWasPressed(_ cell : DefaultSoundTableViewCell, button: UIButton)
}

/* This view controller lets the user choose what they want their default ring tone to be (if no one sets it for them :( ) They can play/stop/set 
 the sound from the cell. The set sound will be highlighted in red.
 */
class SetDefaultSoundTableViewController: UITableViewController, DefaultSoundTableViewCellDelegate {
    var alarmAudioPlayer : AVAudioPlayer?
    
    var softPianoAudioUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "Soft Piano", ofType: "wav")!)
    
    var soundFiles = ["Epic Wakeup", "Jazz", "John Cena", "Obnoxious Synth", "Peaceful Wakeup", "Shogun", "Soft Guitar", "Soft Piano", "Soft Rock"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try alarmAudioPlayer = AVAudioPlayer(contentsOf: softPianoAudioUrl, fileTypeHint: nil)
            tableView.allowsSelection = false
        } catch{
        }
        tableView.backgroundColor = Colors.offwhite
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        alarmAudioPlayer?.stop()
    }
    
    // Based on which button in the cell is pressed, we play,stop or set the song to be the user's default song choice.
    func cellWasPressed(_ cell : DefaultSoundTableViewCell, button: UIButton){
        let songName = cell.SongNameLabel!.text!
        let songUrl = URL(fileURLWithPath: Bundle.main.path(forResource: songName, ofType: "wav")!)
        do{
            try alarmAudioPlayer = AVAudioPlayer(contentsOf: songUrl, fileTypeHint: nil)
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
    fileprivate func setHighlightedDefault(_ cell: DefaultSoundTableViewCell){
        cell.backgroundColor = Colors.cherry
        cell.SongNameLabel.textColor = Colors.offwhite
    }
    
    //This sets the UI for cells not chosen to be the default ringtone
    fileprivate func setHighlightedNonDefault(_ cell: DefaultSoundTableViewCell){
        cell.backgroundColor = Colors.offwhite
        cell.SongNameLabel.textColor = Colors.plum
    }
    
    var defaultCell: DefaultSoundTableViewCell?
    //Returns the name of the song that is in NSUser defaults as the current default alarm
    
   
    //If the user's alarm has not been set already, it will change the user's alarm notification sound to be the new default ringtone
    fileprivate func setUserPreference(_ songName: String){
        UserDefaults.setDefaultSongName(songName)
        //do by states
        if UserDefaults.getState() == State.userHasSetAlarm{
            Notifications.changeDefaultNotificationSound(songName + ".wav")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if soundFiles.count > 0 {
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundFiles.count
    }
    
    //This sets the song name for each cell and highlights the cell if it contains the default ringtone
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath) as? DefaultSoundTableViewCell {
            let currentSongName = soundFiles[(indexPath as NSIndexPath).row]
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
        return tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath)
    }
    
}
