//
//  SplashController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 04/07/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner

class SplashController: PyConIndiaViewController {

    var logo = UIImageView(frame: CGRectMake(0, 0, 300.0, 300.0))
    var loader = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let defaults = NSUserDefaults.standardUserDefaults()

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

        let image = UIImage(named: "images/pycon2015.png")!
        logo.contentMode = .ScaleAspectFit
        logo.image = image

        loader.center = CGPointMake(view.center.x, CGRectGetMaxY(logo.frame) + 10.0)
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        loader.startAnimating()

        let deviceUUIDRegistered = defaults.stringForKey("uuid")
        if let deviceUUIDReg = deviceUUIDRegistered {
            showApp()
        } else {
            let uuid = NSUUID().UUIDString
            cloud.registerDevice(uuid,
                success: {
                response in
                    println(response)
                },
                error: {
                    responseError in
                    let banner = Banner(title: "Cannot reach server", subtitle: "Please check your internet connection", image: UIImage(named: "Icon"), backgroundColor: UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
            })
        }
    }

    func showApp() {
        cloud.getSchedule({
            scheduleResponse in
            let scheduleResponseString = scheduleResponse.rawString()!
            self.defaults.setValue(scheduleResponseString, forKey: "schedule")
            self.cloud.getRooms({
                roomResponse in
                self.loader.stopAnimating()
                let roomsResponseString = roomResponse.rawString()
                self.defaults.setValue(roomsResponseString, forKey: "rooms")
                let schedule = ScheduleController(usingPreviousData: false)
                self.navigationController?.pushViewController(schedule, animated: true)
                }, error: {
                    errorResponse in
                    self.loader.stopAnimating()
                    if self.isDataStoredAlready() {
                        let schedule = ScheduleController(usingPreviousData: true)
                        self.navigationController?.pushViewController(schedule, animated: true)
                    } else {
                        let banner = Banner(title: "Cannot reach server", subtitle: "Please check your internet connection", image: UIImage(named: "Icon"), backgroundColor: UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0))
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                    }
            })
            },
            error: {
                errorResponse in
                self.loader.stopAnimating()
                if self.isDataStoredAlready() {
                    let schedule = ScheduleController(usingPreviousData: true)
                    self.navigationController?.pushViewController(schedule, animated: true)
                } else {
                    let banner = Banner(title: "No Internet Connection", subtitle: "Please check your internet connection", image: UIImage(named: "Icon"), backgroundColor: UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0))
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                }
            }
        )
    }

}