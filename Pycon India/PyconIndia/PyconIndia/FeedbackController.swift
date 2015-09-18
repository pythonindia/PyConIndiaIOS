//
//  FeedbackController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import DLRadioButton
import BRYXBanner


// Feedback of each presentation
class FeedbackController: PyConIndiaViewController, UITextViewDelegate {

    var scrollView: UIScrollView!
    var session: JSON
    var feedbackUIStructure: JSON!
    var textIdToTextView: [String: UITextView] = [:]
    var choiceIdToFirstChoiceButton: [String: PyconRadioButton] = [:]

    required init(coder aDecoder: NSCoder) {
        session = JSON([:])
        super.init(coder: aDecoder)
    }

    init(session: JSON) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        super.viewDidLoad()
        createBackLogo()
        self.title = "Feedback"
        view.backgroundColor = UIColor.whiteColor()
        let feedbackUIStructureString = defaults.stringForKey("feedback")!
        feedbackUIStructure = JSON(data: feedbackUIStructureString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        var top = navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height + 10.0
        scrollView = UIScrollView(frame: CGRectMake(10.0, top, bounds.width - 20.0, bounds.height - top - 60.0))
        self.view.addSubview(scrollView)

        if session["type"].stringValue == "Workshop" {
            designWorkshopUI()
        } else {
            designTalkUI()
        }

        var submitButton = LoadingButton(
            title: "Submit",
            loadingTitle: "Submitting...",
            frame: CGRectMake(10.0, CGRectGetMaxY(scrollView.frame), bounds.width - 20.0, 40.0),
            color: UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0),
            loadingColor: UIColor(red: 39/255.0, green: 116/255.0, blue: 124/255.0, alpha: 1.0),
            callback: submitPressed)
        view.addSubview(submitButton)

        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func handleKeyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo
        if let info = userInfo {
            /* Get the duration of the animation of the keyboard for when it gets displayed on the screen. We will animate our contents using the same animation duration */
            let animationDurationObject = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
            let keyboardEndRectObject = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
            var animationDuration = 0.0
            var keyboardEndRect = CGRectZero
            animationDurationObject.getValue(&animationDuration)
            keyboardEndRectObject.getValue(&keyboardEndRect)
            let window = UIApplication.sharedApplication().keyWindow
            /* Convert the frame from the window's coordinate system to our view's coordinate system */
            keyboardEndRect = view.convertRect(keyboardEndRect, fromView: window)

            /* Find out how much of our view is being covered by the keyboard */
            let intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(view.frame, keyboardEndRect)

            let currentTextView = getCurrentTextView()

            /* Scroll the scroll view up to show the full contents of our view */
            UIView.animateWithDuration(animationDuration, animations: {
                self.scrollView.contentInset = UIEdgeInsets(top: 0,
                    left: 0,
                    bottom: intersectionOfKeyboardRectAndWindowRect.size.height, right: 0)
                self.scrollView.scrollRectToVisible(currentTextView.frame, animated: false)
            })
        }
    }

    func getCurrentTextView() -> UITextView {
        var currentTextView: UITextView = textIdToTextView.values.first!
        for textView in textIdToTextView.values {
            if textView.isFirstResponder() {
                currentTextView = textView
            }
        }
        return currentTextView
    }

    func handleKeyboardWillHide(sender: NSNotification) {
        let userInfo = sender.userInfo
        if let info = userInfo{
            let animationDurationObject = info[UIKeyboardAnimationDurationUserInfoKey]
                as! NSValue
            var animationDuration = 0.0; animationDurationObject.getValue(&animationDuration)
            UIView.animateWithDuration(animationDuration, animations: {
                self.scrollView.contentInset = UIEdgeInsetsZero
            })
        }
    }

    func designWorkshopUI() {
        designUI(feedbackUIStructure["Workshop"])
    }

    func designTalkUI() {
         designUI(feedbackUIStructure["Talk"])
    }

    func designUI(structure: JSON) {
        var previousHeight: CGFloat = 0.0
        var choices = structure["choice"].arrayValue
        for choice in choices {
            let titleLabel = UILabel()
            scrollView.addSubview(titleLabel)
            titleLabel.numberOfLines = 0
            titleLabel.text = choice["title"].stringValue
            titleLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 20.0)

            titleLabel.snp_makeConstraints({ (make) -> Void in
                make.centerX.equalTo(scrollView)
                make.top.equalTo(previousHeight)
                make.width.equalTo(scrollView.frame.size.width)
                make.height.greaterThanOrEqualTo(20.0)
            })
            titleLabel.setNeedsLayout()
            titleLabel.layoutIfNeeded()

            previousHeight = CGRectGetMaxY(titleLabel.frame)

            var allowed_choices = choice["allowed_choices"].arrayValue
            allowed_choices.sort({$0["value"].intValue < $1["value"].intValue})
            let firstChoiceJSON = allowed_choices.first!
            let firstButton = PyconRadioButton(frame: CGRectMake(0, previousHeight, scrollView.frame.size.width, 20.0))
            firstButton.id = firstChoiceJSON["id"].intValue
            firstButton.value = firstChoiceJSON["value"].intValue
            firstButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            firstButton.setTitle(firstChoiceJSON["title"].stringValue, forState: UIControlState.Normal)
            firstButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            scrollView.addSubview(firstButton)

            previousHeight = CGRectGetMaxY(firstButton.frame)
            var otherButtons: [DLRadioButton] = []

            for (index, allowedChoice) in enumerate(allowed_choices) {
                if index == 0 {
                    continue
                }
                let button = PyconRadioButton(frame: CGRectMake(0, previousHeight, scrollView.frame.size.width, 20.0))
                button.id = allowedChoice["id"].intValue
                button.value = allowedChoice["value"].intValue
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                button.setTitle(allowedChoice["title"].stringValue, forState: UIControlState.Normal)
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                scrollView.addSubview(button)
                previousHeight = CGRectGetMaxY(button.frame)
                otherButtons.append(button)
            }
            firstButton.otherButtons = otherButtons
            previousHeight += 20.0
            choiceIdToFirstChoiceButton[choice["id"].stringValue] = firstButton
        }

        var texts = structure["text"].arrayValue
        for text in texts {
            let titleLabel = UILabel()
            scrollView.addSubview(titleLabel)
            titleLabel.numberOfLines = 0
            titleLabel.text = text["title"].stringValue
            titleLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 20.0)

            titleLabel.snp_makeConstraints({ (make) -> Void in
                make.centerX.equalTo(scrollView)
                make.top.equalTo(previousHeight)
                make.width.equalTo(scrollView.frame.size.width)
                make.height.greaterThanOrEqualTo(20.0)
            })
            titleLabel.setNeedsLayout()
            titleLabel.layoutIfNeeded()

            previousHeight = CGRectGetMaxY(titleLabel.frame)

            var textView = UITextView(frame: CGRectMake(0.0, previousHeight, scrollView.frame.size.width, 150.0))
            textView.delegate = self
            textView.layer.borderColor = UIColor.grayColor().CGColor
            textView.layer.borderWidth = 1.0
            textView.layer.cornerRadius = 3.0
            textView.returnKeyType = UIReturnKeyType.Done
            textView.font = UIFont(name: "HelveticaNeue-Condensed", size: 15.0)
            textView.textContainerInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
            textView.tintColor = UIColor.blackColor()
            textView.text = "(Optional)"
            textView.textColor = UIColor.grayColor()
            scrollView.addSubview(textView)

            previousHeight = CGRectGetMaxY(textView.frame)
            textIdToTextView[text["id"].stringValue] = textView
        }

        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, previousHeight)
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func submitPressed(sender: LoadingButton) {
        var jsonToSend: [String: AnyObject] = [:]
        jsonToSend["schedule_item_id"] = session["id"].intValue
        var choices: [[String: AnyObject]] = []
        var texts: [[String: AnyObject]] = []
        sender.showLoading()
        for (id, option) in choiceIdToFirstChoiceButton {
            let selectedButton = option.selectedButton()
            if let selected = selectedButton {
                let json = ["id": id.toInt()!, "value_id": selectedButton.id]
                choices.append(json)
            } else {
                let banner = Banner(title: "Anything not marked as optional is required!", subtitle: "", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:231/255, green:76/255, blue:60/255, alpha:1.0))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                banner.didDismissBlock = sender.stopLoading
                banner.didTapBlock = sender.stopLoading
                return
            }
        }
        for (id, textView) in textIdToTextView {
            if textView.text.trimmed() != "(Optional)" {
                let json = ["id": id.toInt()!, "text": textView.text!]
                texts.append(json as! [String : AnyObject])
            }
        }
        jsonToSend["text"] = texts
        jsonToSend["choices"] = choices
        cloud.sendFeedback(jsonToSend,
            success: {
                response in
                sender.stopLoading()
                if let error = response["error"].string {

                } else {
                    var feedbackSessionIdMap = self.defaults.dictionaryForKey("feedbackSessionIdMap") as! [String: Int]
                    println(feedbackSessionIdMap)
                    feedbackSessionIdMap[String(self.session["id"].intValue)] = 1
                    self.defaults.setObject(feedbackSessionIdMap, forKey: "feedbackSessionIdMap")
                    self.defaults.synchronize()
                }
                self.navigationController?.popViewControllerAnimated(true)
            }, error: {
                error in
                let banner = Banner(title: "Cannot reach server", subtitle: "Please check your internet connection", image: UIImage(named: "Icon"), backgroundColor: UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                banner.didDismissBlock = sender.stopLoading
                banner.didTapBlock = sender.stopLoading
        })
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "(Optional)" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "(Optional)"
            textView.textColor = UIColor.grayColor()
        }
        textView.resignFirstResponder()
    }
}