//
//  ScheduleController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SwiftDate
import BRYXBanner

// The schedule
class ScheduleController: PyConIndiaViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    let tabbedPagerHeight: CGFloat = 44.0
    var bottomPager: TabbedPageView!
    var pageViews: [UIScrollView] = []
    var rooms: [Int: Room] = [:]
    var roomIdImage: [Int: UIImage] = [
        1: UIImage(named: "images/pyconAudi1.png")!,
        2: UIImage(named: "images/pyconAudi2.png")!,
        3: UIImage(named: "images/pyconAudi3.png")!,
        4: UIImage(named: "images/pyconAudi4.png")!,
    ]

    let favoriteInactiveImage = UIImage(named: "images/pyconFavorite.png")!
    let favoriteActiveImage = UIImage(named: "images/pyconFavoriteActive.png")!

    let feedbackInactiveImage = UIImage(named: "images/pyconFeedback.png")!
    let feedbackActiveImage = UIImage(named: "images/pyconFeedbackActive.png")!
    let DAY1 = "2015-10-02"
    let DAY2 = "2015-10-03"
    let DAY3 = "2015-10-04"
    var usingPreviousData: Bool
    var sessionIdToSession: [Int: JSON] = [:]
    var feedbackImageViews: [Int: UIImageView] = [:]

    required init(coder aDecoder: NSCoder) {
        usingPreviousData = false
        super.init(coder: aDecoder)
    }

    init(usingPreviousData: Bool) {
        self.usingPreviousData = usingPreviousData
        super.init(nibName: nil, bundle: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let feedbackSessionIdMap = self.defaults.dictionaryForKey("feedbackSessionIdMap") as! [String: Int]
        for (id, feedbackImageView) in feedbackImageViews {
            if let feedback = feedbackSessionIdMap[String(id)] {
                if feedback == 1 {
                    feedbackImageView.image = feedbackActiveImage
                } else {
                    feedbackImageView.image = feedbackInactiveImage
                }
            }
        }
    }

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        createSimpleLogo()
        self.title = "PyConIndia 2015"
        self.designPager()
        view.backgroundColor = UIColor.whiteColor()

        if self.usingPreviousData {
            let banner = Banner(title: "Warning! No Internet Connection", subtitle: "Displaying previously stored schedule. May not match with current schedule.", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:231/255, green:76/255, blue:60/255, alpha:1.0))
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }

        var top = navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height

        scrollView = UIScrollView(frame: CGRectMake(0, top, bounds.width, bounds.height - tabbedPagerHeight - top))
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        scrollView.alwaysBounceHorizontal = false
        scrollView.bounces = false
        let pagesScrollViewSize = self.scrollView.frame.size
        self.scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * 3.0, height: pagesScrollViewSize.height)
        self.view.addSubview(scrollView)

        setupPages(true)
        for index in 1...3 {
            loadPage(index)
        }

        let defaults = NSUserDefaults.standardUserDefaults()
        let scheduleString = defaults.stringForKey("schedule")!
        let roomString = defaults.stringForKey("rooms")!
        let scheduleResponse = JSON(data: scheduleString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        let roomResponse = JSON(data: roomString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        let rms = roomResponse.arrayValue
        for rm in rms {
            let id = rm["id"].intValue
            let name = rm["name"].stringValue
            let note = rm["note"].stringValue
            let room = Room(id: id, name: name, note: note)
            self.rooms[id] = room
        }
        designSchedules(scheduleResponse)
    }

    // Returns the current day of the hackathon
    func determineDay() -> Int {
        let currentDate = NSDate()

        let firstPyconDayEnds = NSDate()
        firstPyconDayEnds.set(year: 2015, month: 10, day: 01, hour:23, minute:59, second:59, tz:nil)

        let secondPyconDayEnds = NSDate()
        secondPyconDayEnds.set(year: 2015, month: 10, day: 02, hour: 23, minute: 59, second: 59, tz: nil)

        if currentDate < firstPyconDayEnds {
            return 1
        } else if currentDate >= firstPyconDayEnds && currentDate < secondPyconDayEnds {
            return 2
        } else {
            return 3
        }
    }

    func setupPages(firstTime: Bool) {
        let pageWidth = scrollView.frame.size.width
        let page = firstTime ? determineDay() : Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0))) + 1

        bottomPager.currentPage	= page

        if firstTime {
            scrollView.contentOffset = CGPointMake(scrollView.frame.width * CGFloat(page - 1), scrollView.contentOffset.y)
        }
    }

    func loadPage(page: Int) {
        if page < 1 || page > 3 {
            return
        }

        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page - 1)
        frame.origin.y = 0.0

        var newPageView = UIScrollView(frame: CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height))
        newPageView.contentMode = .ScaleAspectFit
        scrollView.addSubview(newPageView)
        pageViews.append(newPageView)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        setupPages(false)
    }

    func designSchedules(data: JSON) {
        let daysJson = data

        var dayNumber = 0
        for (date, dayJson) in daysJson {
            let pageView = pageViews[dayNumber]
            designSchedule(dayJson, day: dayNumber, pageView: pageView)
            dayNumber += 1
        }
    }

    func timeToDate(time: String) -> NSDate {
        return time.toDate(format: DateFormat.Custom("HH:mm:ss"))!
    }

    func designSchedule(details: JSON, day: Int, pageView: UIScrollView) {

        var top: CGFloat = 28.0
        let slots = details
        let defaults = NSUserDefaults.standardUserDefaults()

        var favoriteSessionIdMap: [String: Int] = defaults.dictionaryForKey("favoriteSessionIdMap") as? [String: Int] ?? [:]
        var feedbackSessionIdMap: [String: Int] = defaults.dictionaryForKey("feedbackSessionIdMap") as? [String: Int] ?? [:]
        var slotsArray: [(NSDate, JSON)] = []
        var timeNsDate: [NSDate : String] = [:]
        for (time, slot) in slots {
            let start_end_time_array = time.explode("-")
            let start_time = timeToDate(start_end_time_array[0].trimmed())
            timeNsDate[start_time] = time
            let end_time = timeToDate(start_end_time_array[1].trimmed())
            slotsArray.append((start_time, slot))
        }
        slotsArray.sort({ $0.0 < $1.0 })

        for (time, slot) in slotsArray {
            let start_end_time_array = timeNsDate[time]!.explode("-")
            let start_time = start_end_time_array[0]
            let end_time = start_end_time_array[1]
            var sessions = slot.arrayValue
            sessions.sort({$0["room_id"].intValue < $1["room_id"].intValue})
            var slotView = UIView(frame: CGRectMake(8.0, top, pageView.frame.size.width - 16.0, 100.0 * CGFloat(sessions.count)))
            top = CGRectGetMaxY(slotView.frame) + 28.0
            pageView.addSubview(slotView)

            var bulletLineTimeContainer = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(slotView.frame) / 5.0, CGRectGetHeight(slotView.frame)))
            slotView.addSubview(bulletLineTimeContainer)

            var bullet = UIView(frame: CGRectMake(0, 0, 12.0, 12.0))
            bullet.layer.cornerRadius = 6.0
            bullet.layer.masksToBounds = true
            bullet.backgroundColor = UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0)
            bulletLineTimeContainer.addSubview(bullet)

            var line = UIView(frame: CGRectMake(3.0, CGRectGetMaxX(bullet.frame) + 16.0, 6.0, CGRectGetHeight(slotView.frame) - CGRectGetHeight(bullet.frame) - 16.0))
            line.backgroundColor = UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0)
            bulletLineTimeContainer.addSubview(line)

            var startTime = UILabel(frame: CGRectMake(12.0, 0.0, CGRectGetWidth(bulletLineTimeContainer.frame) - 12.0, 12.0))
            var start_datetime = start_time.trimmed()
            var startTimeObj = start_datetime.toDate(format: DateFormat.Custom("HH:mm:ss"))!

            startTime.text = startTimeObj.toString(format: DateFormat.Custom("hh:mm a"))
            startTime.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 11.0)
            startTime.textAlignment = .Right
            bulletLineTimeContainer.addSubview(startTime)

            var endTime = UILabel(frame: CGRectMake(12.0, 14.0, CGRectGetWidth(bulletLineTimeContainer.frame) - 12.0, 12.0))
            var end_datetime = end_time.trimmed()
            var endTimeObj = end_datetime.toDate(format: DateFormat.Custom("HH:mm:ss"))!

            endTime.text = endTimeObj.toString(format: DateFormat.Custom("hh:mm a"))
            endTime.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 11.0)
            endTime.textAlignment = .Right
            bulletLineTimeContainer.addSubview(endTime)

            var iconsContainer = UIView(frame: CGRectMake(CGRectGetMaxX(bulletLineTimeContainer.frame), 0, CGRectGetWidth(slotView.frame) / 5.0, CGRectGetHeight(slotView.frame)))
            slotView.addSubview(iconsContainer)

            for (index, session) in enumerate(sessions) {
                let room_id = session["room_id"].intValue
                let audiImage = UIImageView(frame: CGRectMake(0, CGFloat(index) * 100.0, 15.0, 15.0))
                audiImage.contentMode = UIViewContentMode.ScaleAspectFit
                audiImage.image = roomIdImage[room_id]
                audiImage.center = CGPointMake(iconsContainer.frame.size.width / 2, audiImage.center.y)
                iconsContainer.addSubview(audiImage)

                let audiLabel = UILabel(frame: CGRectMake(0, CGRectGetMaxY(audiImage.frame) + 1.0, CGRectGetWidth(iconsContainer.frame), 12.0))
                audiLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 11.0)
                audiLabel.text = "AUDI"
                audiLabel.textAlignment = .Center
                iconsContainer.addSubview(audiLabel)

                let favoriteView = UIView(frame: CGRectMake((CGRectGetWidth(iconsContainer.frame) -  50.0) / 2.0, CGRectGetMaxY(audiLabel.frame) + 20.0, 25.0, 25.0))
                iconsContainer.addSubview(favoriteView)
                let favoriteImageView = UIImageView(frame: CGRectMake(5.0, 5.0, 15.0, 15.0))
                favoriteImageView.userInteractionEnabled = false
                favoriteImageView.contentMode = UIViewContentMode.ScaleAspectFit
                let sessionId = String(session["id"].intValue)
                let favorite = favoriteSessionIdMap[sessionId] ?? 0
                favoriteImageView.image = favorite == 0 ? favoriteInactiveImage : favoriteActiveImage
                favoriteView.tag = session["id"].intValue
                favoriteView.addSubview(favoriteImageView)
                let favoriteViewTap = UITapGestureRecognizer(target: self, action: Selector("favoriteTapped:"))
                favoriteView.addGestureRecognizer(favoriteViewTap)

                let feedbackView = UIView(frame: CGRectMake(CGRectGetMaxX(favoriteView.frame), CGRectGetMaxY(audiLabel.frame) + 20.0, 25.0, 25.0))
                iconsContainer.addSubview(feedbackView)
                var feedbackImageView = UIImageView(frame: CGRectMake(5.0, 5.0, 15.0, 15.0))
                feedbackImageViews[session["id"].intValue] = feedbackImageView
                feedbackImageView.userInteractionEnabled = false
                feedbackImageView.contentMode = UIViewContentMode.ScaleAspectFit
                let feedback = feedbackSessionIdMap[sessionId] ?? 0
                feedbackImageView.image = feedback == 0 ? feedbackInactiveImage : feedbackActiveImage
                feedbackView.tag = session["id"].intValue
                feedbackView.addSubview(feedbackImageView)

                favoriteSessionIdMap[String(session["id"].intValue)] = favoriteSessionIdMap[String(session["id"].intValue)] ?? 0
                feedbackSessionIdMap[String(session["id"].intValue)] = feedbackSessionIdMap[String(session["id"].intValue)] ?? 0
            }

            var textContainer = UIView(frame: CGRectMake(CGRectGetMaxX(iconsContainer.frame), 0, CGRectGetWidth(slotView.frame) * 3.0 / 5.0, CGRectGetHeight(slotView.frame)))
            slotView.addSubview(textContainer)

            for (index, session) in enumerate(sessions) {
                sessionIdToSession[session["id"].intValue] = session
                let tapGesture = UITapGestureRecognizer(target: self, action: Selector("descriptionTapped:"))

                let heading = UILabel(frame: CGRectMake(0, CGFloat(index) * 100.0, CGRectGetWidth(textContainer.frame), 0.0))
                heading.tag = session["id"].intValue
                heading.lineBreakMode = NSLineBreakMode.ByWordWrapping
                heading.numberOfLines = 2
                heading.adjustsFontSizeToFitWidth = true
                heading.text = session["name"].stringValue.trimmed().replaceMatches("\r\n", withString: " ", ignoreCase: false)
                heading.font = UIFont(name: "HelveticaNeue-Bold", size: 11.0)

                var options: NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading
                var labelRect = heading.attributedText.boundingRectWithSize(CGSizeMake(heading.frame.size.width, 35.0), options: options, context: nil)
                heading.frame = CGRectMake(0, CGFloat(index) * 100.0, CGRectGetWidth(textContainer.frame), labelRect.size.height)
                textContainer.addSubview(heading)

                let description = UILabel(frame: CGRectMake(0, CGRectGetMaxY(heading.frame) + 1.0, CGRectGetWidth(textContainer.frame), 0.0))
                description.userInteractionEnabled = true
                description.tag = session["id"].intValue
                description.lineBreakMode = NSLineBreakMode.ByWordWrapping
                description.numberOfLines = 4
                description.font = UIFont(name: "HelveticaNeue-Light", size: 9.0)
                description.text = session["session"]["description"].stringValue.trimmed().replaceMatches("\r\n", withString: " ", ignoreCase: false)
                description.addGestureRecognizer(tapGesture)

                options = NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading
                labelRect = description.attributedText.boundingRectWithSize(CGSizeMake(description.frame.size.width, 100.0 - (CGRectGetHeight(heading.frame) + 1.0)), options: options, context: nil)
                description.frame = CGRectMake(0, CGRectGetMaxY(heading.frame) + 1.0, CGRectGetWidth(textContainer.frame), labelRect.size.height)
                textContainer.addSubview(description)
            }
        }


        defaults.setObject(favoriteSessionIdMap, forKey: "favoriteSessionIdMap")
        defaults.setObject(feedbackSessionIdMap, forKey: "feedbackSessionIdMap")
        defaults.synchronize()

        pageView.contentSize = CGSizeMake(pageView.contentSize.width, top)
    }

    func descriptionTapped(sender: UIGestureRecognizer) {
        let session = sessionIdToSession[sender.view!.tag]
        if let ses = session {
            let presentation = PresentationController(session: ses)
            self.navigationController?.pushViewController(presentation, animated: true)
        }
    }

    func favoriteTapped(sender: UITapGestureRecognizer) {
        var favoriteSessionIdMap = defaults.dictionaryForKey("favoriteSessionIdMap") as! [String: Int]
        let setValue = favoriteSessionIdMap[String(sender.view!.tag)]
        let valueToSet = setValue == 0 ? 1 : 0

        if let view = sender.view {
            for subview in view.subviews {
                if let imageView = subview as? UIImageView {
                    imageView.image = valueToSet == 0 ? favoriteInactiveImage : favoriteActiveImage
                    favoriteSessionIdMap[String(sender.view!.tag)] = valueToSet
                    defaults.setObject(favoriteSessionIdMap, forKey: "favoriteSessionIdMap")
                    defaults.synchronize()
                }
            }
        }
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        for (sessionId, favorite) in favoriteSessionIdMap {
            if favorite == 1 {
                let session = sessionIdToSession[sessionId.toInt()!]!
                let eventDate = session["event_date"].stringValue
                let startTime = session["start_time"].stringValue
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = eventDate + " " + startTime
                let startTimeOb = dateFormat.dateFromString(dateString)?.addSeconds(-90)
                let currentDate = NSDate()
                var difference = startTimeOb!.timeIntervalSinceDate(currentDate)
                var notification = UILocalNotification()
                notification.timeZone = NSTimeZone(abbreviation: "IST")
                notification.alertTitle = session["type"].stringValue.capitalized + " is about to start!"
                notification.alertAction = "Open"
                notification.alertBody = session["name"].stringValue
                notification.fireDate = NSDate(timeIntervalSinceNow: difference)
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
    }

    func designPager() {
        bottomPager = TabbedPageView(frame: CGRectMake(0, bounds.height - tabbedPagerHeight, bounds.width, tabbedPagerHeight))
        let bottomPagerIcon = UIImage(named: "images/pyconDay.png")

        bottomPager.addButton("DAY 1", icon: bottomPagerIcon, action: {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.width * CGFloat(0), self.scrollView.contentOffset.y)
                },
                completion: {
                    completed in
            })
        })

        bottomPager.addButton("DAY 2", icon: bottomPagerIcon, action: {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.width * CGFloat(1), self.scrollView.contentOffset.y)
                },
                completion: {
                    completed in
            })
        })

        bottomPager.addButton("DAY 3", icon: bottomPagerIcon, action: {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.width * CGFloat(2), self.scrollView.contentOffset.y)
                },
                completion: {
                    completed in
            })
        })
        self.view.addSubview(bottomPager)
    }
}