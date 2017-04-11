//
//  SetPreferencesViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 2/2/17.
//  Copyright © 2017 Laura Brouckman. All rights reserved.
//

import UIKit
import AVFoundation

class SetPreferencesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var soundPlayButton: UIButton!
    @IBOutlet weak var soundEditButton: UIButton!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var saveAlarmButton: UIButton!
    
    var alarmAudioPlayer : AVAudioPlayer?
    var soundFiles = ["Epic Wakeup", "Jazz", "John Cena", "Obnoxious Synth", "Peaceful Wakeup", "Shogun", "Soft Guitar", "Soft Piano", "Soft Rock"]
    
    
    var previousDate : Date?
    fileprivate var remoteDB = Database()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SetPreferencesViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        
        self.saveAlarmButton.backgroundColor = Colors.white
        self.saveAlarmButton.layer.cornerRadius = 6.0
        self.saveAlarmButton.layer.borderWidth = 1.0
        self.saveAlarmButton.layer.borderColor = Colors.midblue.cgColor
        self.saveAlarmButton.layer.shadowColor = Colors.midblue.cgColor
        self.saveAlarmButton.layer.shadowOpacity = 0.9
        self.saveAlarmButton.layer.shadowRadius = 2.0
        self.saveAlarmButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        
        if previousDate != nil {
            datePicker.date = previousDate!
        }
        datePicker.datePickerMode = UIDatePickerMode.time
        messageTextField.delegate = self
        datePicker.backgroundColor = Colors.white
        datePicker.setValue(Colors.midblue, forKeyPath: "textColor")
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        alarmAudioPlayer?.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let soundName = UserDefaults.getDefaultSongName()
        soundLabel.text = soundName
        
        if let prevMessage = Foundation.UserDefaults.standard.value(forKey: "User Default Message") as? String {
            messageTextField.text = prevMessage
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        messageTextField.resignFirstResponder()
        if let message = messageTextField.text {
            if let userId = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String{
                remoteDB.uploadUserMessageToDatabase(message, forUser: userId)
                Foundation.UserDefaults.standard.setValue(message, forKey: "User Default Message")
            }
            
        }
        return true
    }
    
    
    
    @IBAction func playAlarm(_ sender: UIButton) {
        let songName = soundLabel.text
         let songUrl = URL(fileURLWithPath: Bundle.main.path(forResource: songName, ofType: "wav")!)
        do {
            try alarmAudioPlayer = AVAudioPlayer(contentsOf: songUrl, fileTypeHint: nil)
            switch sender.titleLabel!.text! {
            case "Play":
                alarmAudioPlayer?.play()
            case "Stop":
                alarmAudioPlayer?.pause()
            default: break

            }
        } catch {}
        if soundPlayButton.titleLabel!.text == "Play" {
            soundPlayButton.setTitle("Stop", for: .normal)
        } else {
            soundPlayButton.setTitle("Play", for: .normal)
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    @IBAction func saveAlarm(_ sender: UIButton) {
        setAlarm()
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setAlarm() {
        if let message = messageTextField.text {
            if let userId = Foundation.UserDefaults.standard.value(forKey: "PhoneNumber") as? String{
                remoteDB.uploadUserMessageToDatabase(message, forUser: userId)
                Foundation.UserDefaults.standard.setValue(message, forKey: "User Default Message")
            }
            
        }
        let date = ensureDateIsTomorrow(datePicker.date)
        UserDefaults.setState(State.userHasSetAlarm)
        UserDefaults.setAlarmDate(date)
        UserDefaults.userAlarmBeenSet(false)
        UserDefaults.storeFriendWhoSetAlarm("")
        remoteDB.addAlarmTimeToDatabase(date)
        if #available(iOS 10, *){
            Notifications.AddAlarmNotification10(at: date, title: "Wake up", body: "You charmed yourself!", songName: UserDefaults.getDefaultSongName() + ".wav")
        }
        else{
            Notifications.AddAlarmNotification9(at: date, title: "Wake up", body: "You charmed yourself!", songName: UserDefaults.getDefaultSongName() + ".wav")}
    }
    
    fileprivate func ensureDateIsTomorrow(_ date: Date) -> Date{
        let currentDay = Date()
        var newDate = date
        if (currentDay as NSDate).earlierDate(date) == date {
            newDate = date.addingTimeInterval(60*60*24)
        }
        return newDate
        //if the set date is earlier than current date, return less date + a day.
    }
    
}
