//
//  RegionsAppDelegate.swift
//  Regions
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/22.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The application delegate which creates the window and root view controller.
 */
import UIKit
import CoreLocation

@UIApplicationMain
@objc(RegionsAppDelegate)
class RegionsAppDelegate: NSObject, UIApplicationDelegate {
    
    @IBOutlet var window: UIWindow?
    
    private var locationManager: CLLocationManager?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
    
    // Custom getter for the read-only property viewController.
    
    // lazy accessor implementation
    private lazy var viewController: RegionsViewController? = self.window?.rootViewController as! RegionsViewController?
    
    func applicationDidEnterBackground(application: UIApplication) {
        /*
         Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
         If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
         */
        
        // Reset the icon badge number to zero.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
    }
    
    
    func applicationWillEnterForeground(application: UIApplication) {
        /*
         Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
         */
    }
    
    
    func applicationDidBecomeActive(application: UIApplication) {
        /*
         Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
         */
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        /*
         Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
         Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
         */
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Save data if appropriate.
    }
    
    
}