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
    var loader = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.whiteColor()
        logo.center = view.center
        view.addSubview(logo)

        let defaults = NSUserDefaults.standardUserDefaults()
        let image = UIImage(named: "images/pycon2015.png")!
        logo.contentMode = .ScaleAspectFit
        logo.image = image

        loader.center = CGPointMake(view.center.x, CGRectGetMaxY(logo.frame) + 10.0)
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        loader.startAnimating()

        cloud.getSchedule({
            response in
            self.loader.stopAnimating()
            self.view.layer.removeAllAnimations()
            let responseString = response.rawString()!
            defaults.setValue(responseString, forKey: "schedule")
            let schedule = ScheduleController()
            self.navigationController?.pushViewController(schedule, animated: true)
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