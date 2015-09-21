//
//  PresentationController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import SwiftyJSON
import SnapKit
import BRYXBanner

// Contains details of a presentation: Talks / Workshops
class PresentationController: PyConIndiaViewController {

    let ProposalTargetAudience = [
        1: "Beginner",
        2: "Intermediate",
        3: "Advanced"
    ]

    var session: JSON
    var feedBackButton: UIButton!

    required init(coder aDecoder: NSCoder) {
        session = JSON([:])
        super.init(coder: aDecoder)
    }

    init(session: JSON) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let feedbackSessionIdMap = self.defaults.dictionaryForKey("feedbackSessionIdMap") as! [String: Int]
        if let feedback = feedbackSessionIdMap[String(session["id"].intValue)] {
            if feedback == 1 {
                feedBackButton.hidden = true
            }
        }
    }

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        createBackLogo()
        self.title = "Details"
        view.backgroundColor = UIColor.whiteColor()
        designUI()
    }

    func designUI() {
        var top = navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        let viewHeight = bounds.height - top

        let titleString = session["session"]["title"].stringValue
        let titleHTML = "<h1>\(titleString)</h1>"

        var authorString = session["session"]["author"].stringValue
        if authorString.trimmed() != "" {
            authorString = "<b>by:</b> " + authorString
        }
        var authorHTML = "<i>\(authorString)</i>\n\r\n\r"

        var authorInfo = session["session"]["speaker_info"].stringValue
        if authorInfo != "" {
            authorHTML += "<b>About author:</b> <i>\(authorInfo)</i>\n\r\n\r"
        }

        var section = session["session"]["section"].stringValue
        if section != "" {
            authorHTML += "<i><b>Section:</b> \(section)</i>\n\r\n\r"
        }

        if let targetAudience = session["session"]["target_audience"].int {
            if let actualTarget = ProposalTargetAudience[targetAudience] {
                authorHTML += "<i><b>Target audience:</b> \(actualTarget)</i>\n\r\n\r"
            }
        }

        var markDownString = titleHTML + authorHTML + session["session"]["description"].stringValue
        var markdown = Markdown()
        let outputHtml: String = markdown.transform(markDownString)

        var description = UIWebView(frame: CGRectMake(20.0, top, bounds.width - 40.0, viewHeight))
        description.opaque = false
        description.backgroundColor = UIColor.clearColor()
        description.loadHTMLString(outputHtml, baseURL: nil)
        view.addSubview(description)

        feedBackButton = UIButton(frame: CGRectMake(bounds.width - 50.0, bounds.height - 50.0, 40.0, 40.0))
        feedBackButton.addTarget(self, action: Selector("feedbackButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        feedBackButton.layer.cornerRadius = 20.0
        if isAllowedToGiveFeedback() {
            feedBackButton.backgroundColor = UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0)
        } else {
            feedBackButton.backgroundColor = UIColor.grayColor()
        }

        if session["type"].stringValue == "Talk" || session["type"].stringValue == "Workshop" {
            view.addSubview(feedBackButton)
        }

        let buttonImage = UIImage(named: "images/feedback.png")
        var buttonImageView = UIImageView(frame: CGRectMake(10.0, 10.0, 20.0, 20.0))
        buttonImageView.image = buttonImage
        buttonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        feedBackButton.addSubview(buttonImageView)

        description.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        description.scrollView.showsVerticalScrollIndicator = false

        let timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("changeButtonColorAndActivateIfOnTime"), userInfo: nil, repeats: true)
    }

    func changeButtonColorAndActivateIfOnTime() {
        if isAllowedToGiveFeedback() {
            feedBackButton.backgroundColor = UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0)
        } else {
            feedBackButton.backgroundColor = UIColor.grayColor()
        }
    }

    func isAllowedToGiveFeedback() -> Bool {
        let currentDate = NSDate()
        let eventDate = session["event_date"].stringValue.explode("-")
        let eventEndTime = session["end_time"].stringValue.explode(":")

        let timeToGiveFeedbackStart = NSDate().set(year: eventDate[0].toInt(), month: eventDate[1].toInt(), day: eventDate[2].toInt(), hour: eventEndTime[0].toInt(), minute: eventEndTime[1].toInt(), second: eventEndTime[2].toInt(), tz: "IST")
        let timeToGiveFeedbackEnd = timeToGiveFeedbackStart.dateByAddingTimeInterval(604800)
        if currentDate >= timeToGiveFeedbackStart && currentDate <= timeToGiveFeedbackEnd {
            return true
        } else {
            return false
        }
    }

    func feedbackButtonPressed() {
        if isAllowedToGiveFeedback() {
            let feebackController = FeedbackController(session: session)
            self.navigationController?.pushViewController(feebackController, animated: true)
        } else {
            let banner = Banner(title: "Not allowed", subtitle: "Feedback submission only allowed for 7 days starting from the end of the session.", image: UIImage(named: "Icon"), backgroundColor: UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0))
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }
    }

}