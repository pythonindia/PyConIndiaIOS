//
//  SplashController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 04/07/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit

class SplashController: PyConIndiaViewController {

    var logo = UIImageView(frame: CGRectMake(0, 0, 300.0, 300.0))

    override func viewDidLoad() {
        logo.center = view.center
        view.addSubview(logo)

        let defaults = NSUserDefaults.standardUserDefaults()
        let image = UIImage(named: "images/pycon2015.png")!
        logo.contentMode = .ScaleAspectFit
        logo.image = image

        animateLogo()
        cloud.getSchedule({
            response in
            self.view.layer.removeAllAnimations()
            let responseString = response.rawString()!
            defaults.setValue(responseString, forKey: "schedule")
            self.performSegueWithIdentifier("toScheduleController", sender: self)
            },
            error: nil
        )

    }

    func animateLogo() {
        UIView.animateWithDuration(2.5, delay: 0.0, options: UIViewAnimationOptions.Repeat | UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.Autoreverse, animations: {
            },
            completion: nil)
    }

}