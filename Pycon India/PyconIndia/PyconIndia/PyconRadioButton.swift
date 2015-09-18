//
//  PyconRadioButton.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 18/09/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit
import DLRadioButton

class PyconRadioButton: DLRadioButton {
    var id: Int!
    var value: Int!

    override func selectedButton() -> PyconRadioButton! {
        if selected {
            return self
        }
        for button in otherButtons {
            if let but = button as? PyconRadioButton {
                if but.selected {
                    return but
                }
            }
        }
        return nil
    }
}