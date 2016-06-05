//
//  CreateAlarmViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/24/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//  Used below for tutorial for interacting with audioRecorder
////https://www.hackingwithswift.com/example-code/media/how-to-record-audio- using-avaudiorecorder

import UIKit
import AVFoundation
import CoreData
//Maybe have a delegate that is the alarm itself, this comes from inital view controller
//Set sound will set audio part

class CreateNewAlarmViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate{
    private var audioSession: AVAudioSession!
    private var recorder: AVAudioRecorder?
    private var soundPlayer: AVAudioPlayer?
    private var recordFileName: String?
    var userID: String?
    private let remoteDB = Database()
    var managedObjectContext: NSManagedObjectContext?
    private var saved = false
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var alarmMessageLabel: UITextField!
    @IBOutlet weak var alarmNameTextEdit: UITextField!
    
    private var state: RecordButtonStates!
    private enum RecordButtonStates : String{
        case Initial = "Record"
        case Recording = "Press to stop"
        case Stopped = "Re-record"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        alarmMessageLabel.delegate = self
        playButton.enabled = false
        audioSession = AVAudioSession.sharedInstance()
        recordFileName = randomStringWithLength(20) as String
        recordFileName = recordFileName! + ".caf"
        
        do{try  audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord) }catch{print("didnt set category")}
        do{
            try  audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        }catch let error as NSError{
            print("in here")
            print(error)}
        do {
            state = RecordButtonStates.Initial
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        print("was allowed ")
                    } else {
                        // Maybe segue back? Not sure yet
                    }
                }
            }
        } catch { }
    }
    
    //Randomly generate a string that can be used as filenames, so that they're different every time
    private func randomStringWithLength (len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for _ in 0 ..< len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString
    }
    
    
    @IBAction func recordPushed(sender: UIButton) {
        
        if  state == RecordButtonStates.Initial || state == RecordButtonStates.Stopped {
            state = RecordButtonStates.Recording
            startRecording()
        } else {
            state = RecordButtonStates.Stopped
            finishRecording(success: true)
        }
        
    }
    
    @IBAction func playUserRecording(sender: UIButton) {
//        recorder?.updateMeters()
//        print(recorder?.averagePowerForChannel(0))
//        print(recorder?.averagePowerForChannel(1))
//        print(recorder?.averagePowerForChannel(2))
//        print(recorder?.averagePowerForChannel(3))
//        print(" is the average decibel level")
        //Load in recorded sound into the audioplayer
        if state != RecordButtonStates.Initial {
            soundPlayer?.play()
        }
        else{
            soundPlayer?.stop()
        }
    }
    
    // In case a phone call comes in.
    @objc func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        soundPlayer?.stop()
    }
    
    private func audioPlayerEndInterruption(player: AVAudioPlayer) {
        soundPlayer?.play()
    }
    
    private func startRecording() {
        let settings = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000.0,
                         AVNumberOfChannelsKey: 1 as NSNumber, AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        do {
            recorder = try AVAudioRecorder(URL: getAudioUrl(), settings: settings)
            recorder?.recordForDuration(NSTimeInterval(29)) //Making sure maximum is under 30 seconds
//            recorder?.meteringEnabled
            recorder?.delegate = self
            recorder?.record()
            recordButton.setTitle(state.rawValue, forState: .Normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    //This function stops the audio recorder, sets it equal to nil, and then sets the button text appropiately
    private func finishRecording(success success: Bool) {
        recorder?.stop()
        saved = false
        //This will reset the recorder if they want to record again.
        if success {
            //The state will be in stopped mode already, and so we won't need to change it.
            playButton.enabled = true
            recordButton.setTitle(state.rawValue, forState: .Normal)
            do{
                try soundPlayer = AVAudioPlayer(contentsOfURL: getAudioUrl(), fileTypeHint: nil)
                soundPlayer?.prepareToPlay()
                soundPlayer?.volume = 1.0
            }
            catch let error as NSError{print(error)}
            
        } else {
            state = RecordButtonStates.Initial
            recordButton.setTitle(RecordButtonStates.Initial.rawValue, forState: .Normal)
        }
    }
    
    //Returns the correct audio url
    private func getAudioUrl() -> NSURL{
        let docDict = getDocumentsDirectory() as NSString
        let soundPath = docDict.stringByAppendingPathComponent(recordFileName!)
        return NSURL(fileURLWithPath: soundPath)
    }
    
    //Helper function for getting the current directory
    private func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        //Maybe set wake up message or in function below
        return true
    }
    
    
    //When the user goes back, whatever the recorded will be uploaded to the DB and set to the user's audio
    //If nothing was recorded, nothing happens (error printed to console saying that the audio file doesn't exist which is good)
    //Possible: if they don't name their alarm, have an alert that tells them that name is required
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            remoteDB.userInProcessOfBeingSet(forUser: userID!, inProcess: false)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        remoteDB.userInProcessOfBeingSet(forUser: userID!, inProcess: false)
    }

    private func alertNotSaved() {
        let alert = UIAlertController(title: "You haven't saved your alarm yet!", message: "Would you like to save this alarm before leaving? ", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(
            title: "Save",
            style: .Default)
        {  [weak weakSelf = self] (action: UIAlertAction) ->  Void in
            weakSelf?.saveAlarm()
            weakSelf?.remoteDB.userInProcessOfBeingSet(forUser: (weakSelf?.userID)!, inProcess: false)
            weakSelf?.navigationController?.popViewControllerAnimated(true)
            }
        )
        alert.addAction(UIAlertAction(
            title: "Don't Save",
            style: .Default)
        {  [weak weakSelf = self] (action: UIAlertAction) ->  Void in
            weakSelf?.remoteDB.userInProcessOfBeingSet(forUser: (weakSelf?.userID)!, inProcess: false)
            weakSelf?.navigationController?.popViewControllerAnimated(true)
            }
        )
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .Default)
        {  (action: UIAlertAction) ->  Void in
            }
        )
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func goBack() {
        if !saved {
            alertNotSaved()
        } else {
            navigationController?.popViewControllerAnimated(true)

        }
    }
    
    
    private func alertNoAlarmName() {
        let alert = UIAlertController(title: "No Alarm Title", message: "You must enter a title for your alarm before saving", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .Default)
        {  (action: UIAlertAction) -> Void in
            return
            }
        )
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveAlarm() {
        if let x = alarmNameTextEdit.text {
            if x.characters.count > 0 {
                let audioUrl = getAudioUrl()
                remoteDB.uploadFileToDatabase(audioUrl, forUser: userID!)
                if let username = NSUserDefaults.standardUserDefaults().valueForKey("Username") as? String{
                    remoteDB.changeWhoSetAlarm(username, forUser: userID!)
                }
                updateCoreData(alarmNameTextEdit.text!, alarmMessage: nil, audioFilename: audioUrl.absoluteString, imageFilename: nil)
                let message = alarmMessageLabel.text
                if message?.characters.count > 0 {
                    remoteDB.uploadWakeUpMessageToDatabase(message!, forUser: userID!)
                }
                saved = true
            } else {
                alertNoAlarmName()
            }
        } else {
            alertNoAlarmName()
        }
    }
    
    private func updateCoreData(alarmName: String, alarmMessage: String?, audioFilename: String?, imageFilename: String?) {
        managedObjectContext?.performBlockAndWait { [weak weakSelf = self] in
            let _ = Alarm.addAlarmToDB(
                alarmName,
                alarmMessage: alarmMessage,
                audioFilename: audioFilename,
                imageFilename: imageFilename,
                inManagedObjectContext: (weakSelf?.managedObjectContext)!)
            do {
                try (weakSelf?.managedObjectContext)!.save()
            } catch let error {
                print(error)
            }
        }
    }
}
