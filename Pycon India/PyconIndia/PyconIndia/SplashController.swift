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
            scheduleResponse in
                let scheduleResponseString = scheduleResponse.rawString()!
                defaults.setValue(scheduleResponseString, forKey: "schedule")
                self.cloud.getRooms({
                     roomResponse in
                        self.loader.stopAnimating()
                        let roomsResponseString = roomResponse.rawString()
                        defaults.setValue(roomsResponseString, forKey: "rooms")
                        let schedule = ScheduleController()
                        self.navigationController?.pushViewController(schedule, animated: true)
                }, error: nil)
            },
            error: nil
        )

    }

}