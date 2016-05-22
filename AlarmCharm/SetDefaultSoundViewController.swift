//
//  SetDefaultViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit
import AVFoundation
class SetDefaultSoundViewController: UIViewController {
    
    
    //MAKE A DICTIONARY MAPPING BUTTON NAME TO URL, AND SO ANY BUTTON JUST PLAYS OR STOPS OR RESTARTS BASED ON NAME OF BUTTON HAHAHAH
    var alarmAudioPlayer : AVAudioPlayer?
    var softPianoAudioUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Alarm_Soothing_Piano", ofType: "wav")!)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            
            try alarmAudioPlayer = AVAudioPlayer(contentsOfURL: softPianoAudioUrl, fileTypeHint: nil)
        } catch{
        }
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playMusic(sender: UIButton) {
        alarmAudioPlayer?.play()
    }

}