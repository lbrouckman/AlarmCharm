//
//  ContentViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 8/21/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("new content view controller being made")
        self.imageView.image = UIImage(named: self.imageFile)
        self.titleLabel.text = self.titleText
        self.titleLabel.textColor = Colors.cherry
        self.view.backgroundColor = Colors.offyellow
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
