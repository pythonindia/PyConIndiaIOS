//
//  AppDelegate.swift
//  PyconIndia
//
//  Created by Rishi Mukherjee on 28/06/15.
//  Copyright (c) 2015 Rishi Mukherjee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        let rootViewController = SplashController()
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        self.window!.rootViewController = navigationController
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        // Custmoize the navigation bar
        var navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barStyle = UIBarStyle.Black
        navigationBarAppearance.barTintColor = UIColor(red: 60/255.0, green: 178/255.0, blue: 192/255.0, alpha: 1.0)
        let navigationFont = UIFont(name: "Helvetica-Light", size: 15.0)!
        navigationBarAppearance.titleTextAttributes = [NSFontAttributeName: navigationFont, NSForegroundColorAttributeName: UIColor.whiteColor()]
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

