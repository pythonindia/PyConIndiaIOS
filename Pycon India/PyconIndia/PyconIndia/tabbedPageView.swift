//
//  tabbedPageView.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 02/07/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit

class TabbedPageButton: UIButton {
    var buttonAction: (() -> ())
    var buttonText: String
    var buttonIcon: UIImage?
    var number: Int = 1
    private var parent: TabbedPageView

    init(frame: CGRect, buttonText: String, buttonAction: (() -> ()), buttonIcon: UIImage?, parent: TabbedPageView) {
        self.buttonText = buttonText
        self.buttonIcon = buttonIcon
        self.buttonAction = buttonAction
        self.parent = parent
        super.init(frame: frame)
        addTarget(self, action: Selector("buttonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    func designButton() {

        // Remove all subviews
        for subview in subviews {
            if let sv = subview as? UIView {
                sv.removeFromSuperview()
            }
        }

        if let icon = buttonIcon {
            // Icon has to be given, so adjust accordingly

            // Create the container
            var container = UIView(frame: CGRectMake(10.0, 10.0, frame.size.width - 20.0, frame.size.height - 20.0))
            let containerCenterX = container.frame.size.width / 2.0
            let containerCenterY = container.frame.size.height / 2.0
            self.addSubview(container)

            // Create the iconView to be put inside the container
            var iconView = UIImageView(image: icon)
            iconView.frame = CGRectMake(0, 0, 15.0, 15.0)
            iconView.center = CGPointMake(iconView.center.x, container.frame.size.height / 2.0)
            iconView.contentMode = .ScaleAspectFit
            container.addSubview(iconView)

            // Create the label to be put inside the container right to the iconView
            var textLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(iconView.frame) + 6.0, 0, 0, iconView.frame.size.height))
            textLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 14.0)
            textLabel.text = buttonText
            let textLabelWidth = textLabel.intrinsicContentSize().width
            var textLabelFrame = textLabel.frame
            textLabelFrame.size.width = textLabelWidth
            textLabel.frame = textLabelFrame
            textLabel.center = CGPointMake(textLabel.center.x, container.frame.size.height / 2.0)
            container.addSubview(textLabel)

            // Adjust the container Frame
            container.frame = CGRectMake(0, 0, 15.0 + 6.0 + textLabelWidth, container.frame.size.height)
            container.center = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0)
            container.userInteractionEnabled = false
        } else {
            // No icon. So text has to be centered
            var textLabel = UILabel(frame: CGRectMake(10.0, 10.0, frame.size.width - 20.0, frame.size.height - 20.0))
            textLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 14.0)
            textLabel.text = buttonText
            textLabel.textAlignment = .Center
            self.addSubview(textLabel)
        }
    }

    internal func buttonPressed() {
        parent.currentPage = number
        self.buttonAction()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TabbedPageView: UIView {

    private var buttons: [TabbedPageButton] = []
    private var buttonTexts: [String] = []
    private var buttonActions: [(() -> ())] = []
    private var buttonIcons: [UIImage?] = []
    private var lineView: UIView = UIView()

    private var _showLine = true
    private var _currentPage = 0
    private var buttonNumber = 1

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Add a shadow on top
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, -1.5)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = shadowPath.CGPath

        // set Background color
        self.backgroundColor = UIColor.whiteColor()
    }

    var currentPage: Int {
        set (page) {
            _currentPage = page
            animateLineToCurrentTab()
        }

        get {
            return _currentPage
        }
    }

    var showLine: Bool {
        set {
            // Drawline only if it is not already shown
            _showLine = showLine
            if _showLine {
                lineView.hidden = false
            } else {
                lineView.hidden = true
            }
        }
        get {
            return _showLine
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func addButton(text: String, icon: UIImage?, action: (() -> ())) {
        var button = TabbedPageButton(frame: CGRectZero, buttonText: text, buttonAction: action, buttonIcon: icon, parent: self)
        button.number = buttonNumber
        self.addSubview(button)
        buttons.append(button)
        arrangeButtons()
        buttonNumber++
    }

    private func arrangeButtons() {
        let totalFrameWidth = CGRectGetWidth(frame)
        let widthOfEachButton: CGFloat = totalFrameWidth / CGFloat(buttons.count)
        var left: CGFloat = 0.0
        var top: CGFloat = 0.0
        var width: CGFloat = widthOfEachButton
        var height: CGFloat = frame.size.height

        for (index, button) in enumerate(buttons) {
            button.frame = CGRectMake(left, top, width, height)
            button.designButton()
            left = CGRectGetMaxX(button.frame)
        }
        drawLine(widthOfEachButton)
    }

    private func drawLine(width: CGFloat) {
        lineView.frame = CGRectMake(0, 0, width, 3.0)
        lineView.backgroundColor = UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0)
        addSubview(lineView)
    }

    private func animateLineToCurrentTab() {
        let totalFrameWidth = CGRectGetWidth(frame)
        let widthOfEachButton: CGFloat = totalFrameWidth / CGFloat(buttons.count)

        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                var lineViewFrame = self.lineView.frame
                lineViewFrame.origin.x = widthOfEachButton * CGFloat(self._currentPage - 1)
                self.lineView.frame = lineViewFrame
            },
            completion: {
                completed in
        })
    }
}