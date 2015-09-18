//
//  LoadingButton.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 18/09/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//
import Foundation
import UIKit


class LoadingButton: UIButton {

    var color: UIColor
    var loadingColor: UIColor
    var title: String
    var loadingTitle: String
    var loader: UIActivityIndicatorView!
    var callback: ((sender: LoadingButton) -> ())

    init(title: String, loadingTitle: String, frame: CGRect, color: UIColor, loadingColor: UIColor, callback: ((sender: LoadingButton) -> ())) {
        self.color = color
        self.loadingColor = loadingColor
        self.title = title
        self.loadingTitle = loadingTitle
        self.callback = callback
        super.init(frame: frame)
        initialize()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initialize() {
        layer.cornerRadius = 2.0
        backgroundColor = color
        setTitle(title, forState: UIControlState.Normal)
        setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        titleLabel!.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 14.0)
        addTarget(self, action: Selector("loadingButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        loader = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loader.hidesWhenStopped = true
        loader.frame = CGRectMake(20.0, (CGRectGetHeight(frame) - 30.0) / 2.0, 30.0, 30.0)
        self.addSubview(loader)
    }

    func showLoading() {
        loader.startAnimating()
        setTitle(loadingTitle, forState: UIControlState.Normal)
        backgroundColor = loadingColor
        enabled = false
    }

    func stopLoading() {
        loader.stopAnimating()
        setTitle(title, forState: UIControlState.Normal)
        backgroundColor = color
        enabled = true
    }

    func loadingButtonPressed(sender: LoadingButton) {
        callback(sender: sender)
    }
}