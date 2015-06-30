//
//  ScheduleController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation

// The schedule
class ScheduleController: PyConIndiaViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        println("Getting schedule")
        cloud.getSchedule({
            response in
                println(response)
            },
            error: nil
        )
    }

}