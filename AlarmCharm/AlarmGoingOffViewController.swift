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
    
    fileprivate var alarmSetBy : String? {
        didSet {
            alarmSetByLabel?.text = "Charmed by: " + alarmSetBy!
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AlarmGoingOffViewController.songEnded(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: self.player?.currentItem
        )
        self.player?.play()
    }
    
    //If the default alarm went off, give them a default picture
    fileprivate func setPhotoToDefault() {
        let imageURL = URL(fileURLWithPath: Bundle.main.path(forResource: "default_wakeup_photo", ofType: "jpg")!)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak weakSelf = self] in
            let contentsOfURL = try? Data(contentsOf: imageURL)
            DispatchQueue.main.async {
                if imageURL == URL(fileURLWithPath: Bundle.main.path(forResource: "default_wakeup_photo", ofType: "jpg")!) {
                    if let imageData = contentsOfURL {
                        weakSelf?.imageView?.image = UIImage(data: imageData)
                        weakSelf?.makeRoomForImage()
                    }
                }
            }
        }
    }
    
    //Add image to view by getting it from the local file system
    fileprivate func addImageToView(_ fileName: String) {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let imagePath = libraryPath + "/Images"
        let filePath = imagePath + "/" + fileName
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: imagePath, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("error" + error1.description)
        }
        let myURL = URL(fileURLWithPath: filePath)
        if let imageData = try? Data(contentsOf: myURL) {
            imageView?.image = UIImage(data: imageData)
            makeRoomForImage()
        }
    }
    
    //This code is to size the image correctly, it comes from Paul Hegerty's iTunes lecture on imagePicker
    fileprivate func makeRoomForImage() {
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
                imageView.frame = CGRect.zero
            }
            preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
        }
    }
    
    
    func songEnded(_ notification: Notification){
        player?.seek(to: kCMTimeZero)
    }
    var player : AVPlayer?
    
    fileprivate func prepareToPlayMusicFromFileSystem(_ fileName:String){
        let playerItem = AVPlayerItem(url : getURlFromFileSystem(fileName))
        player = AVPlayer(playerItem: playerItem)
    }
    fileprivate func prepareToPlayMusicFromDefault(_ defaultSongName :String) {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: defaultSongName, ofType: "wav")!)
        let playerItem = AVPlayerItem(url : url)
        player = AVPlayer(playerItem: playerItem)
        
    }
    
    fileprivate func setWakeupMessage(){
        self.wakeupMessage = UserDefaults.getWakeUpMessage()
    }
    
    fileprivate func setAlarmSetBy() {
        self.alarmSetBy = UserDefaults.getFriendWhoSetAlarm()
    }
    
    @IBOutlet weak var playAlarmButton: UIButton!
    
    @IBAction func playPushed(_ sender: UIButton) {
        player?.play()
    }
    
    
    @IBAction func PausePushed(_ sender: UIButton) {
        player?.pause()
    }
    
    
    
    /*
     Get the sound from the local file system so that the user can play it again if they want to.
     */
    fileprivate func getURlFromFileSystem(_ fileName: String) -> URL{
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let soundsPath = libraryPath + "/Sounds"
        let filePath = soundsPath + "/" + fileName
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: soundsPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error1 as NSError {
            print("error" + error1.description)
        }
        let myURL = URL(fileURLWithPath: filePath)
        return myURL
    }
    
    
}
