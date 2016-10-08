//
//  CreateAlarmViewController.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/24/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//  Used below for tutorial for interacting with audioRecorder
////https://www.hackingwithswift.com/example-code/media/how-to-record-audio- using-avaudiorecorder
// Both

import UIKit
import AVFoundation
import CoreData
import MobileCoreServices
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/* This class holds the functionality for creating an alarm.
 */
class CreateNewAlarmViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate var audioSession: AVAudioSession!
    fileprivate var recorder: AVAudioRecorder?
    fileprivate var soundPlayer: AVAudioPlayer?
    fileprivate var recordFileName: String?
    fileprivate var imageFileName: String?
    var userID: String?
    fileprivate let remoteDB = Database()
    var managedObjectContext: NSManagedObjectContext?
    fileprivate var audioRecorded = false
    
    fileprivate var saved = false {
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
    
    fileprivate var state: RecordButtonStates!
    fileprivate enum RecordButtonStates : String{
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
        playButton.isEnabled = false
        audioSession = AVAudioSession.sharedInstance()
        recordFileName = randomStringWithLength(20) as String
        recordFileName = recordFileName! + ".caf"
        imageFileName = randomStringWithLength(20) as String
        imageFileName = imageFileName! + ".png"
        
        do{try  audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord) }catch{print("didnt set category")}
        do{
            try  audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        }catch let error as NSError{
            print(error)}
        do {
            state = RecordButtonStates.Initial
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { (allowed: Bool) -> Void in
                DispatchQueue.main.async {
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
    fileprivate func randomStringWithLength (_ len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for _ in 0 ..< len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString
    }
    
    //Start recording audio
    @IBAction func recordPushed(_ sender: UIButton) {
        
        if  state == RecordButtonStates.Initial || state == RecordButtonStates.Stopped {
            state = RecordButtonStates.Recording
            startRecording()
        } else {
            state = RecordButtonStates.Stopped
            finishRecording(success: true)
        }
        
    }
    
    //Play back audio
    @IBAction func playUserRecording(_ sender: UIButton) {
        if state != RecordButtonStates.Initial {
            soundPlayer?.play()
        }
        else{
            soundPlayer?.stop()
        }
    }
    
    // In case a phone call comes in.
    @objc func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    /**
    @objc func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        soundPlayer?.stop()
    }
    
    internal func audioPlayerEndInterruption(_ player: AVAudioPlayer) {
        soundPlayer?.play()
    }
    **/
    fileprivate func startRecording() {
        let settings = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000.0,
                         AVNumberOfChannelsKey: 1 as NSNumber, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        do {
            recorder = try AVAudioRecorder(url: getAudioUrl(), settings: settings)
            recorder?.record(forDuration: TimeInterval(29)) //Making sure maximum is under 30 seconds
            //            recorder?.meteringEnabled
            recorder?.delegate = self
            recorder?.record()
            recordButton.setTitle(state.rawValue, for: UIControlState())
        } catch {
            finishRecording(success: false)
        }
    }
    
    //This function stops the audio recorder, sets it equal to nil, and then sets the button text appropiately
    fileprivate func finishRecording(success: Bool) {
        recorder?.stop()
        //This will reset the recorder if they want to record again.
        if success {
            saved = false
            audioRecorded = true
            //The state will be in stopped mode already, and so we won't need to change it.
            playButton.isEnabled = true
            recordButton.setTitle(state.rawValue, for: UIControlState())
            do{
                try soundPlayer = AVAudioPlayer(contentsOf: getAudioUrl(), fileTypeHint: nil)
                soundPlayer?.prepareToPlay()
                soundPlayer?.volume = 1.0
            }
            catch let error as NSError{print(error)}
            
        } else {
            state = RecordButtonStates.Initial
            recordButton.setTitle(RecordButtonStates.Initial.rawValue, for: UIControlState())
        }
    }
    
    //Returns the URL for the audio file
    fileprivate func getAudioUrl() -> URL{
        let docDict = getDocumentsDirectory() as NSString
        let soundPath = docDict.appendingPathComponent(recordFileName!)
        return URL(fileURLWithPath: soundPath)
    }
    
    //Helper function for getting the current directory
    fileprivate func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //Returns URL for the image file
    fileprivate func getImageUrl() -> URL {
        let docDict = getDocumentsDirectory() as NSString
        let imagePath = docDict.appendingPathComponent(imageFileName!)
        return URL(fileURLWithPath: imagePath)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        //Maybe set wake up message or in function below
        return true
    }
    
    //Before the user goes back to the parent controller, mark that the user is no longer in the process of being set
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            remoteDB.userInProcessOfBeingSet(forUser: userID!, inProcess: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        remoteDB.userInProcessOfBeingSet(forUser: userID!, inProcess: false)
    }
    
    //Alert the user before they go back that their alarm has not been saved; give them the option to save (and go back) not save (and go back) or cancel
    fileprivate func alertNotSaved() {
        let alert = UIAlertController(title: "You haven't saved your alarm yet!", message: "Would you like to save this alarm before leaving? ", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(
            title: "Save",
            style: .default)
        {  [weak weakSelf = self] (action: UIAlertAction) ->  Void in
            weakSelf?.saveAlarm()
            weakSelf?.remoteDB.userInProcessOfBeingSet(forUser: (weakSelf?.userID)!, inProcess: false)
            weakSelf?.navigationController?.popViewController(animated: true)
            }
        )
        alert.addAction(UIAlertAction(
            title: "Don't Save",
            style: .default)
        {  [weak weakSelf = self] (action: UIAlertAction) ->  Void in
            weakSelf?.remoteDB.userInProcessOfBeingSet(forUser: (weakSelf?.userID)!, inProcess: false)
            weakSelf?.navigationController?.popViewController(animated: true)
            }
        )
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .default)
        {  (action: UIAlertAction) ->  Void in
            }
        )
        present(alert, animated: true, completion: nil)
        
    }
    
    //Manual segue to parentViewController
    @IBAction func goBack() {
        if !saved {
            alertNotSaved()
        } else {
            navigationController?.popViewController(animated: true)
            
        }
    }
    
    //Alert the user that their alarm has not been named if they try to save it (alarms must have a name in order to be saved)
    fileprivate func alertNoAlarmName() {
        let alert = UIAlertController(title: "No Alarm Title", message: "You must enter a title for your alarm before saving", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default)
        {  (action: UIAlertAction) -> Void in
            return
            }
        )
        present(alert, animated: true, completion: nil)
    }
    
    //Alert the user that they haven't recorded any sound (and alarm needs sound!)
    fileprivate func alertNoAudio() {
        let alert = UIAlertController(title: "No Audio Recorded", message: "You must enter record a sound for your alarm", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default)
        {  (action: UIAlertAction) -> Void in
            return
            }
        )
        present(alert, animated: true, completion: nil)
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
                
                if let username = Foundation.UserDefaults.standard.value(forKey: "Username") as? String{
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
    fileprivate func updateCoreData(_ alarmName: String, alarmMessage: String?, audioFilename: String?, imageFilename: String?) {
        managedObjectContext?.performAndWait { [weak weakSelf = self] in
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //When the take a picture, save it to the local file system under the name getImageUrl()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        saved = false
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        saveImageToFileSystem()
        makeRoomForImage()
        dismiss(animated: true, completion: nil)
    }
    
    func saveImageToFileSystem() {
        if let image = imageView.image {
            if let imageData = UIImagePNGRepresentation(image) {
                try? imageData.write(to: getImageUrl(), options: [.atomic])
            }
        }
    }
    
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
    
}
