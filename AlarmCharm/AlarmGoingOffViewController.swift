//
//  AlarmGoingOffViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/29/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
 
class AlarmGoingOffViewController: UIViewController {
    var playing = false
    
    @IBOutlet weak var wakeupMessageLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    var wakeupMessage : String?{
        didSet{
        wakeupMessageLabel?.text = wakeupMessage
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.hasAlarmBeenSet(){
            prepareToPlayMusicFromFileSystem(Constants.ALARM_SOUND_STORED_FILENAME)
        }else{
            prepareToPlayMusicFromDefault(UserDefaults.getDefaultSongName())
        }
        if UserDefaults.hasImage() {
            addImageToView("test.png")
        }
        
        UserDefaults.clearAlarmDate()
        getWakeUPMessage()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "songEnded:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: self.player!.currentItem
        )
    }
    
    private func addImageToView(fileName: String) {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0]
        let imagePath = libraryPath + "/Images"
        let filePath = imagePath + "/" + fileName
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(imagePath, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("error" + error1.description)
        }
        let myURL = NSURL(fileURLWithPath: filePath)
        if let imageData = NSData(contentsOfURL: myURL) {
            imageView?.image = UIImage(data: imageData)
        }
    }
    
    func songEnded(notification: NSNotification){
    player?.seekToTime(kCMTimeZero)
    }
    var player : AVPlayer?

    private func prepareToPlayMusicFromFileSystem(fileName:String){
        let playerItem = AVPlayerItem(URL : getURlFromFileSystem(fileName))
        player = AVPlayer(playerItem: playerItem)
    }
    private func prepareToPlayMusicFromDefault(defaultSongName :String) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(defaultSongName, ofType: "wav")!)
        let playerItem = AVPlayerItem(URL : url)
        player = AVPlayer(playerItem: playerItem)
        
    }
    
    private func getWakeUPMessage(){
        self.wakeupMessage = UserDefaults.getWakeUpMessage()
    }
    
    @IBOutlet weak var playAlarmButton: UIButton!
    
    
    //One Function will play, other will stop
    
    
    @IBAction func playPushed(sender: UIButton) {
            player?.play()
    }
    
    
    @IBAction func PausePushed(sender: UIButton) {
        player?.pause()
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
