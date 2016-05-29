//
//  AlarmGoingOffViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/29/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import AVFoundation

class AlarmGoingOffViewController: UIViewController {
    var playing = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //Show message
        //Show Image
        //Have option to replay alarm.
        prepareToPlayMusicFromFileSystem(Constants.ALARM_SOUND_STORED_FILENAME)
    }
    var player : AVPlayer?
    /*
     
     */
    private func prepareToPlayMusicFromFileSystem(fileName:String){
        let playerItem = AVPlayerItem(URL : getURlFromFileSystem(fileName))
        player = AVPlayer(playerItem: playerItem)
    }
    
    
    @IBOutlet weak var playAlarmButton: UIButton!
    
    @IBAction func playPushed(sender: UIButton) {
        if playing{
            player?.pause()
            playing = false
            playAlarmButton.titleLabel?.text = "replay alarm"
        }
        else{
            player?.play()
            playing = true
            playAlarmButton.titleLabel?.text = "stop"
        }
    }
    
    /*
     Will be useful once app opens as well to actually play the sound with an av player
     */
    private func getURlFromFileSystem(fileName: String) -> NSURL{
        let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0]
        let soundsPath = libraryPath + "/Sounds"
        let filePath = soundsPath + "/" + fileName
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.createDirectoryAtPath(soundsPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("error" + error1.description)
        }
        let myURL = NSURL(fileURLWithPath: filePath)
        print(myURL)
        return myURL
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
