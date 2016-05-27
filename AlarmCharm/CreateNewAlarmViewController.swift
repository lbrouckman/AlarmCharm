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
//Maybe have a delegate that is the alarm itself, this comes from inital view controller
//Set sound will set audio part

class CreateNewAlarmViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    var audioSession: AVAudioSession!
    var recorder: AVAudioRecorder?
    var soundPlayer : AVAudioPlayer?
    var recordFileName = "test.caf"

    @IBOutlet weak var playButton: UIButton!
    
    private var state: RecordButtonStates!
    private enum RecordButtonStates : String{
        case Initial = "Record"
        case Recording = "Press to stop"
        case Stopped = "Re-record"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.enabled = false
        audioSession = AVAudioSession.sharedInstance()
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //Load in recorded sound into the audioplayer
        if state != RecordButtonStates.Initial {
            soundPlayer?.play()
        }
        else{
            soundPlayer?.stop()
        }
    }
    
    @IBOutlet weak var recordButton: UIButton!

    // In case a phone call comes in.
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        soundPlayer?.stop()
    }
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
        soundPlayer?.play()
    }
    func startRecording() {
        let settings = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000.0,
                         AVNumberOfChannelsKey: 1 as NSNumber, AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        do {
            recorder = try AVAudioRecorder(URL: getAudioUrl(), settings: settings)
            recorder?.delegate = self
            recorder?.record()
            recordButton.setTitle(state.rawValue, forState: .Normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    //This function stops the audio recorder, sets it equal to nil, and then sets the button text appropiately
    func finishRecording(success success: Bool) {
        recorder?.stop()
        //This will reset the recorder if they want to record again.
        if success {
            //The state will be in stopped mode already, and so we won't need to change it.
            playButton.enabled = true
            recordButton.setTitle(state.rawValue, forState: .Normal)
            do{
                print("preparing audio player")
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
        let soundPath = docDict.stringByAppendingPathComponent(recordFileName)
        return NSURL(fileURLWithPath: soundPath)
    }
    
    //Helper function for getting the current directory
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
