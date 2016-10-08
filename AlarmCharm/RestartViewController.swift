//
//  RestartViewController.swift
//  AlarmCharm
//
//  Created by Alexander Carlisle on 8/21/16.
//  Copyright © 2016 Laura Brouckman. All rights reserved.
//

import UIKit

class RestartViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var restartButton: UIButton!
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        let title0 = "Welcome to the AlarmCharm tutorial :). Swipe right to start your journey."
        let homeScreenTitle = "The preferences page allows you to see your current alarm state. Let's set an alarm."
        let setAlarmTitle = "Maybe you are an early bird."
        let backToHomeScreen = "You can now see your set alarm. Now let's set your default ringtone"
        let chooseRingTone = "Choose our alarm sound for tomorrow morning(cena recommended)."
        let backToHomeScreenAgain = "Now let's tell our friend's how we want to be charmed"
        let friendMessage = "Tell your friends how to set your alarm."
        let goCharmFriends = "My mom always said I was charming, so lets go charm some of my friends!"
        let createAlarm = "Here I can record myself singing who let the dogs out and wake them up with this amazing pic."
        let notification = "Oh, look someone has charmed us."
        let homePageAfterBeenCharmed = "Tomorrow morning, at 6:30, Laura's voice, message, and pic will wake us up."
        let timePasses = "Tomorrow morning, you will wake up to ..."
        let alarmGoingOff = "The greatest wake up of your life. Enjoy the app!"
        self.pageTitles = NSArray(objects: title0, homeScreenTitle, setAlarmTitle, backToHomeScreen, chooseRingTone, backToHomeScreenAgain, friendMessage)
//        title7, title8, title9, title10, title11)
        self.pageImages = NSArray(objects: "AlarmCharmLogo", "UnsetPreferences", "EarlyBirdAlarm", "UnsetPreferences", "ChooseJohnCena", "UnsetPreferences", "WakeUpMessage")
//        "tut7", "tut8", "tut9", "tut10", "tut11")
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewControllerNew") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as ContentViewController
        let viewControllers = NSArray(object: startVC) as! [UIViewController]
        self.view.backgroundColor = Colors.cheesecakeCrust
        self.pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0,30, self.view.frame.size.width, self.view.frame.size.height - 2 * self.restartButton.frame.height)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        self.restartButton.setTitleColor(Colors.offwhite, forState: .Normal) 
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restartTutorial(sender: AnyObject) {
        var startVC = self.viewControllerAtIndex(0) as ContentViewController
        var viewControllers = NSArray(object: startVC) as! [UIViewController]
        self.pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
    }
    
    func viewControllerAtIndex(index: Int) -> ContentViewController{
        if( (self.pageTitles.count == 0) || (index > self.pageTitles.count)){
            print("count is 0")
            return ContentViewController()
        }
        let vc : ContentViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewControllerNew") as! ContentViewController
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        print("returning the vc at index", index)
        return vc
    }
    
    // Mark page view controller Datasource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex
        if (index == 0 || index == NSNotFound){
            return nil
        }
        index = index - 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex
        if ( index == NSNotFound){
            print("index not found")
            return nil
        }
        index = index + 1
        if (index == self.pageTitles.count){
            print("index is same as count")
            return nil
        }
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        print("asking for count")
        return self.pageTitles.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        print("asking for index")
        return 0
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
