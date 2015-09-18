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

// Contains details of a presentation: Talks / Workshops
class PresentationController: PyConIndiaViewController {

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
        if authorString != "" {
            authorString = "by: " + authorString
        }
        let authorHTML = "<i>\(authorString)</i>\n\r\n\r"

        var markDownString = titleHTML + authorHTML + session["session"]["description"].stringValue
        var markdown = Markdown()
        let outputHtml: String = markdown.transform(markDownString)

        var description = UIWebView(frame: CGRectMake(20.0, top, bounds.width - 40.0, viewHeight))
        description.opaque = false
        description.backgroundColor = UIColor.clearColor()
        description.loadHTMLString(outputHtml, baseURL: nil)
        view.addSubview(description)

        feedBackButton = UIButton(frame: CGRectMake(20.0, bounds.height - 60.0, bounds.width - 40.0, 40.0))
        feedBackButton.addTarget(self, action: Selector("feedbackButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        feedBackButton.layer.cornerRadius = 3.0
        feedBackButton.backgroundColor = UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0)
        feedBackButton.setTitle("Give Feedback", forState: UIControlState.Normal)
        feedBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        feedBackButton.titleLabel!.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 15.0)
        if session["type"].stringValue == "Talk" || session["type"].stringValue == "Workshop" {
            view.addSubview(feedBackButton)
        }

        let buttonImage = UIImage(named: "images/feedback.png")
        var buttonImageView = UIImageView(frame: CGRectMake(25.0, 7.5, 25.0, 25.0))
        buttonImageView.image = buttonImage
        buttonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        feedBackButton.addSubview(buttonImageView)

        description.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        description.scrollView.showsVerticalScrollIndicator = false
    }

    func feedbackButtonPressed() {
        let feebackController = FeedbackController(session: session)
        self.navigationController?.pushViewController(feebackController, animated: true)
    }

}