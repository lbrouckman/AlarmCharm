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
    @IBOutlet weak var alarmSetByLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var wakeupMessage : String?{
        didSet{
            wakeupMessageLabel?.text = wakeupMessage
        }
    }
    
    private var alarmSetBy : String? {
        didSet {
            alarmSetByLabel?.text = "Set by: " + alarmSetBy!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.hasAlarmBeenSet(){
            prepareToPlayMusicFromFileSystem(Constants.ALARM_SOUND_STORED_FILENAME)
            setWakeupMessage()
            setAlarmSetBy()
            if UserDefaults.hasImage() {
                addImageToView("alarmImage.png")
            }
        }else{
            prepareToPlayMusicFromDefault(UserDefaults.getDefaultSongName())
            setPhotoToDefault()
        }
        
        UserDefaults.clearAlarmDate()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "songEnded:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: self.player!.currentItem
        )
    }
    
    private func setPhotoToDefault() {
        let imageURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("default_wakeup_photo", ofType: "jpg")!)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
            let contentsOfURL = NSData(contentsOfURL: imageURL)
            dispatch_async(dispatch_get_main_queue()) {
                if imageURL == NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("default_wakeup_photo", ofType: "jpg")!) {
                    if let imageData = contentsOfURL {
                        weakSelf?.imageView?.image = UIImage(data: imageData)
                        weakSelf?.makeRoomForImage()
                    }
                }
            }
        }
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
            makeRoomForImage()
        }
    }
    
    private func makeRoomForImage() {
        if imageView.image != nil {
            let aspectRatio = imageView.image!.size.width / imageView.image!.size.height
            var extraHeight: CGFloat = 0
            if aspectRatio > 0 {
                if let width = imageView.superview?.frame.size.width {
                    let height = width / aspectRatio
                    extraHeight = height - imageView.frame.height
                    imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                }
            } else {
                extraHeight = -imageView.frame.height
                imageView.frame = CGRectZero
            }
            preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
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
    
    private func setWakeupMessage(){
        self.wakeupMessage = UserDefaults.getWakeUpMessage()
    }
    
    private func setAlarmSetBy() {
        self.alarmSetBy = UserDefaults.getFriendWhoSetAlarm()
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
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
