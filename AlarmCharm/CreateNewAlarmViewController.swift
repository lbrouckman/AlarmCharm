//
//  CreateAlarmViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/24/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//  Used below for tutorial for interacting with audioRecorder
////https://www.hackingwithswift.com/example-code/media/how-to-record-audio- using-avaudiorecorder

import UIKit
import AVFoundation
import CoreData
import MobileCoreServices

/* This class holds the functionality for creating an alarm.
 */
class CreateNewAlarmViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var audioSession: AVAudioSession!
    private var recorder: AVAudioRecorder?
    private var soundPlayer: AVAudioPlayer?
    private var recordFileName: String?
    private var imageFileName: String?
    var userID: String?
    private let remoteDB = Database()
    var managedObjectContext: NSManagedObjectContext?
    private var audioRecorded = false
    
    private var saved = false {
        didSet {
            if saved {
                savedLabel.text = "✓"
            } else {
                savedLabel.text = ""
            }
        }
    }
    @IBOutlet weak var savedLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var alarmMessageLabel: UITextField!
    @IBOutlet weak var alarmNameTextEdit: UITextField!
    
    private var state: RecordButtonStates!
    private enum RecordButtonStates : String{
        case Initial = "Record"
        case Recording = "Stop"
        case Stopped = "Re-Record"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        saved = false
        alarmNameTextEdit.delegate = self
        alarmMessageLabel.delegate = self
        playButton.enabled = false
        audioSession = AVAudioSession.sharedInstance()
        recordFileName = randomStringWithLength(20) as String
        recordFileName = recordFileName! + ".caf"
        imageFileName = randomStringWithLength(20) as String
        imageFileName = imageFileName! + ".png"
        
        do{try  audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord) }catch{print("didnt set category")}
        do{
            try  audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        }catch let error as NSError{
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
    
    //Start recording audio
    @IBAction func recordPushed(sender: UIButton) {
        
        if  state == RecordButtonStates.Initial || state == RecordButtonStates.Stopped {
            state = RecordButtonStates.Recording
            startRecording()
        } else {
            state = RecordButtonStates.Stopped
            finishRecording(success: true)
        }
        
    }
    
    //Play back audio
    @IBAction func playUserRecording(sender: UIButton) {
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
        //This will reset the recorder if they want to record again.
        if success {
            saved = false
            audioRecorded = true
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
    
    //Returns the URL for the audio file
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
    
    //Returns URL for the image file
    private func getImageUrl() -> NSURL {
        let docDict = getDocumentsDirectory() as NSString
        let imagePath = docDict.stringByAppendingPathComponent(imageFileName!)
        return NSURL(fileURLWithPath: imagePath)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        //Maybe set wake up message or in function below
        return true
    }
    
    //Before the user goes back to the parent controller, mark that the user is no longer in the process of being set
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
    
    //Alert the user before they go back that their alarm has not been saved; give them the option to save (and go back) not save (and go back) or cancel
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
    
    //Manual segue to parentViewController
    @IBAction func goBack() {
        if !saved {
            alertNotSaved()
        } else {
            navigationController?.popViewControllerAnimated(true)
            
        }
    }
    
    //Alert the user that their alarm has not been named if they try to save it (alarms must have a name in order to be saved)
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
    
    //Alert the user that they haven't recorded any sound (and alarm needs sound!)
    private func alertNoAudio() {
        let alert = UIAlertController(title: "No Audio Recorded", message: "You must enter record a sound for your alarm", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .Default)
        {  (action: UIAlertAction) -> Void in
            return
            }
        )
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //Save the alarm (making sure it has a title/audio, save it to both the local database and set it to the friend's alarm in the remote database
    @IBAction func saveAlarm() {
        if let x = alarmNameTextEdit.text {
            if x.characters.count > 0 {
                if !audioRecorded {
                    alertNoAudio()
                    return
                }
                let audioUrl = getAudioUrl()
                remoteDB.uploadFileToDatabase(audioUrl, forUser: userID!, fileType: "Audio")
                
                if let username = NSUserDefaults.standardUserDefaults().valueForKey("Username") as? String{
                    remoteDB.changeWhoSetAlarm(username, forUser: userID!)
                }
                
                let message = alarmMessageLabel.text
                if message?.characters.count > 0 {
                    remoteDB.uploadWakeUpMessageToDatabase(message!, forUser: userID!)
                }
                
                let imageUrl = getImageUrl()
                remoteDB.uploadFileToDatabase(imageUrl, forUser:userID!, fileType: "Image")
                
                updateCoreData(alarmNameTextEdit.text!, alarmMessage: message, audioFilename: audioUrl.absoluteString, imageFilename: imageUrl.absoluteString)
                saved = true
            } else {
                alertNoAlarmName()
            }
        } else {
            alertNoAlarmName()
        }
    }
    
    //Adds an alarm to coreData
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saved = false
    }
    
    
    // MARK -- IMAGE
    // all of the imageViewContainer Functionality (from Paul Hegerty's iTunes lecture)
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            imageViewContainer.addSubview(imageView)
        }
    }
    
    var imageView = UIImageView()
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //When the take a picture, save it to the local file system under the name getImageUrl()
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        saved = false
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        saveImageToFileSystem()
        makeRoomForImage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImageToFileSystem() {
        if let image = imageView.image {
            if let imageData = UIImagePNGRepresentation(image) {
                imageData.writeToURL(getImageUrl(), atomically: true)
            }
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
    
}
