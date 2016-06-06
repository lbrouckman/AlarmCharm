//
//  AlarmGoingOffViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/29/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Alexander Carlisle

import UIKit
import AVFoundation
import Firebase

/* This view controller is loaded when the user opens their alarm - it shows the image/message (if there was one) and who set their alarm. It also lets them replay the sound
 and go back to the home screen of the app */
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
        UserDefaults.hasImage(false)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(AlarmGoingOffViewController.songEnded(_:)),
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: self.player!.currentItem
        )
    }
    
    //If the default alarm went off, give them a default picture
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
    
    //Add image to view by getting it from the local file system
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
    
    //This code is to size the image correctly, it comes from Paul Hegerty's iTunes lecture on imagePicker
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
    
    @IBAction func playPushed(sender: UIButton) {
        player?.play()
    }
    
    
    @IBAction func PausePushed(sender: UIButton) {
        player?.pause()
    }
    
    
    
    /*
     Get the sound from the local file system so that the user can play it again if they want to.
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
    
    
}
