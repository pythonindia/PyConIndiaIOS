//
//  PresentationController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation

// Contains details of a presentation: Talks / Workshops
class PresentationController: PyConIndiaViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

}