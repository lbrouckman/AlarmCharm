//
//  LoadingScreenViewController.swift
//  AlarmCharm
//
//  Created by Elizabeth Brouckman on 2/7/17.
//  Copyright © 2017 Laura Brouckman. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController {
    var launchedBefore = false
    override func viewDidLoad() {
        super.viewDidLoad()
    }

     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //DO ANIMATION HERE!!!
        launchedBefore = Foundation.UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            self.performSegue(withIdentifier: "showHomeScreen", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showWelcomeScreen", sender: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
