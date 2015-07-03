//
//  ScheduleController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit

// The schedule
class ScheduleController: PyConIndiaViewController {

    let bounds = UIScreen.mainScreen().bounds

    override func viewDidLoad() {
        super.viewDidLoad()
        println("Getting schedule")
        createSimpleLogo()
        self.title = "PyConIndia 2015"
        self.designUI()
        cloud.getSchedule({
            response in
                println(response)
            },
            error: nil
        )
    }

    func designUI() {
        var bottomPager = TabbedPageView(frame: CGRectMake(0, bounds.height - 44.0, bounds.width, 44.0))
        let bottomPagerIcon = UIImage(named: "images/pyconDay.png")

        bottomPager.addButton("DAY 1", icon: bottomPagerIcon, action: {

        })

        bottomPager.addButton("DAY 2", icon: bottomPagerIcon, action: {

        })

        bottomPager.addButton("DAY 3", icon: bottomPagerIcon, action: {

        })
        self.view.addSubview(bottomPager)
    }
}