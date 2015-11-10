//
//  AppDelegate.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 20/10/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // MARK: Settings stuff
        self.registerDefaultsFromSettingsBundle() // Custom function that attempts to make settings/defaults work transparently. Alternative requires hardcoding the default settings in two seperate places (HELL NO)
        
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
    
    /**
    *  Let's mimic core data and make the swiftcoap instance a lazy var
    *  I still don't see the difference between this and a singleton. Is the difference that we're doing dependency injection by passing responsibility to the viewController before the view controller tries to use it? As in the viewController will be using its own reference (but NOT instance) of this class.
    *
    *  @param instance I don't get this lol
    *
    *  @return returns a SCClient, which lets you send and recieve CoAP messages
    */
    
    lazy var coapClient: SCClient =  {
            let tabBarController: UITabBarController = self.window?.rootViewController as! UITabBarController
            let liveView = tabBarController.viewControllers?[0] as! LiveViewController
        // I REALLY shouldn't be force casting but error handling inside a closure inside a lazy var is a bit beyond me right now.
        
            let client: SCClient = SCClient(delegate: liveView) // what should I initialise as the delegate?
            // client.sendToken = true // don't think i need this, it's the default
            return client
        
        // Observe view gets control of the SCCLient first since the user starts there. If they segue, responsibility will be passed along.
        // In theory I could use tabBarController.selectedViewController instead, but since this will get called before the interface loads, what would be selected? The first one?

    }() // end closure for lazy loading of SCClient
    
    enum SwiftCoAPInitError: ErrorType {
        case CouldNotInitialise
    }
    
    // Based on a non-compiling example given in a stackexchange answer (http://stackoverflow.com/a/27949098/3959735) – it was broken and requires a bizarre cast? Still not sure its even working but it looks ok on the debugger?
    func registerDefaultsFromSettingsBundle(){
        
        print(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())
        let defs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defs.synchronize()
        
        var settingsBundle: NSString = NSBundle.mainBundle().pathForResource("Settings", ofType: "bundle")!
        if(settingsBundle.containsString("")){
            NSLog("Could not find Settings.bundle");
            return;
        }
        var settings: NSDictionary = NSDictionary(contentsOfFile: settingsBundle.stringByAppendingPathComponent("Root.plist"))!
        var preferences: NSArray = settings.objectForKey("PreferenceSpecifiers") as! NSArray
        var defaultsToRegister: NSMutableDictionary = NSMutableDictionary(capacity: preferences.count)
        
        for prefSpecification in preferences {
            if (prefSpecification.objectForKey("Key") != nil) {
                let key: NSString = prefSpecification.objectForKey("Key")! as! NSString
                if !key.containsString("") {
                    let currentObject: AnyObject? = defs.objectForKey(key as String)
                    if currentObject == nil {
                        // not readable: set value from Settings.bundle
                        let objectToSet: AnyObject? = prefSpecification.objectForKey("DefaultValue")
                        defaultsToRegister.setObject(objectToSet!, forKey: key)
                        NSLog("Setting object \(objectToSet) for key \(key)")
                    }else{
                        //already readable: don't touch
                        NSLog("Key \(key) is readable (value: \(currentObject)), nothing written to defaults.");
                    }
                }
            }
        }
        defs.registerDefaults(defaultsToRegister as [NSObject:AnyObject] as! [String: AnyObject] )
        defs.synchronize()
        print(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())
    }
    
    
    
}

