//
//  ViewController.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import UIKit

// Common view controller functions will be here and other view controllers inherit from this.
class PyConIndiaViewController: UIViewController {

    let cloud = Cloud()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createSimpleLogo() {
        var backIcon = UIImage(named: "images/footerlogo.png")
        var backView = UIImageView(frame: CGRectMake(0.0, 0.0, 30.0, 30.0))
        backView.image = backIcon
        backView.contentMode = UIViewContentMode.ScaleAspectFit
        var responseButton = UIButton(frame: backView.frame)
        responseButton.addTarget(self, action: "backButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        backView.addSubview(responseButton)
        var backButton = UIBarButtonItem(customView: backView)
        self.navigationItem.leftBarButtonItem = backButton
    }

    func backButtonPressed() {

    }

    func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        let imageRef = image.CGImage

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()

        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)

        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)

        let newImageRef = CGBitmapContextCreateImage(context) as CGImage
        let newImage = UIImage(CGImage: newImageRef)

        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}

