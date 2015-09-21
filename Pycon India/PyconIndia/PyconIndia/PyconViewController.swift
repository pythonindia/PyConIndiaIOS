//
//  ViewController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import UIKit
import SwiftyJSON

// Common view controller functions will be here and other view controllers inherit from this.
class PyConIndiaViewController: UIViewController {

    let cloud = Cloud()
    let bounds = UIScreen.mainScreen().bounds
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createSimpleLogo() {
        var backIcon = UIImage(named: "images/footerlogo.png")
        var backView = UIImageView(frame: CGRectMake(0.0, 0.0, 30.0, 30.0))
        backView.image = backIcon
        backView.contentMode = UIViewContentMode.ScaleAspectFit
        var responseButton = UIButton(frame: backView.frame)
        backView.addSubview(responseButton)
        var backButton = UIBarButtonItem(customView: backView)
        self.navigationItem.leftBarButtonItem = backButton
    }

    func createBackLogo() {
        var backIcon = UIImage(named: "images/back.png")
        var responseButton = UIButton(frame: CGRectMake(0.0, 0.0, 35.0, 35.0))
        responseButton.addTarget(self, action: "backButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        var backView = UIImageView(frame: CGRectMake(7.5, 7.5, 20.0, 20.0))
        backView.image = backIcon
        backView.contentMode = UIViewContentMode.ScaleAspectFit
        responseButton.addSubview(backView)
        var backButton = UIBarButtonItem(customView: responseButton)
        self.navigationItem.leftBarButtonItem = backButton
    }

    func createRefreshLogo() {
        var refreshIcon = UIImage(named: "images/refresh.png")
        var responseButton = UIButton(frame: CGRectMake(0.0, 0.0, 35.0, 35.0))
        responseButton.addTarget(self, action: "refreshButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        var backView = UIImageView(frame: CGRectMake(7.5, 7.5, 20.0, 20.0))
        backView.image = refreshIcon
        backView.contentMode = UIViewContentMode.ScaleAspectFit
        responseButton.addSubview(backView)
        var backButton = UIBarButtonItem(customView: responseButton)
        self.navigationItem.rightBarButtonItem = backButton
    }

    func refreshButtonPressed() {

    }

    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func isDataStoredAlready() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let scheduleString = defaults.stringForKey("schedule")
        let roomString = defaults.stringForKey("rooms")

        if let room = roomString {
            if let schedule = scheduleString {
                return true
            }
        }
        return false
    }

}

