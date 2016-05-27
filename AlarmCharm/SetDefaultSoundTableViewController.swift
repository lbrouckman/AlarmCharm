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
        } catch{
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        alarmAudioPlayer?.stop()
    }
    
    func cellWasPressed(cell : DefaultSoundTableViewCell, button: UIButton){
        let songName = cell.SongNameLabel!.text!
        print(songName)
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
        print(NSUserDefaults.standardUserDefaults().dictionaryForKey(Constants.USER_ALARM_DEFAULT)![Constants.USER_KEY_TO_GET_SONG_DEFAULT])
        
        
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
            if defaultSong == nil{
                setUserPreference(currentSongName)
                defaultSong = currentSongName
            }
            if defaultSong == currentSongName {
                defaultCell = cell
                setHighlightedDefault(cell)
            }
            else{
                setHighlightedNonDefault(cell)
            }
            
            cell.delegate = self
            cell.SongNameLabel.text = currentSongName
            return cell
        }
        return tableView.dequeueReusableCellWithIdentifier("SoundCell", forIndexPath: indexPath)
    }
    
    // IF clicked we need to go to user defaults and change default
    // THen we need to change the current notification, if there is one
    // Also when we first make default we need to see if there is already a default set
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
