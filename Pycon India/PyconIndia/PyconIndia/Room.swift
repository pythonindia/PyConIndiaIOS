//
//  Room.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 03/07/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit

class Room {

    var id: Int
    var name: String
    var note = ""

    init(id: Int, name: String, note: String) {
        self.id = id
        self.name = name
        self.note = note
    }

}