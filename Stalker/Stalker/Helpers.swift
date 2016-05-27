//
//  Helpers.swift
//  Stalker
//
//  Created by Pavel Hamrik on 22/05/16.
//  Copyright © 2016 Pavel Hamrik. All rights reserved.
//

import UIKit
import CoreLocation


class Helpers {
    
    static let defaults = NSUserDefaults.standardUserDefaults()
    static let logFile = "Logs.log"

    
    static func setDefault(key: String, value: AnyObject) {
        defaults.setObject(value, forKey: key)
    }
    
    static func setDefaultCLLocation(key: String, location: CLLocation) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(location)
        defaults.setObject(data, forKey: key)
    }

    static func getDefaultString(key: String) -> String {
        if defaults.objectForKey(key) != nil {
            return defaults.objectForKey(key) as! String
        }
        return String()
    }
    
    static func getDefaultCLLocation(key: String) -> CLLocation {
        if defaults.objectForKey(key) != nil {
            let data = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey(key) as! NSData)
            return data as! CLLocation
        }
        return CLLocation()
    }

    // store the logs in a file
    static func storeLogs(log: String, overwite: Bool = false, emoji: String = "\u{1F554}", notify: Bool = false) -> String {
        print("StoreLogs: Received: " + log)
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(logFile)
            var contents = String()
            
            // reading
            do {
                contents = try String(contentsOfURL: path, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("StoreLogs: Read error.")
            }
            
            // writing
            do {
                // schedule a local notification if the app runs in the background
                if notify && UIApplication.sharedApplication().applicationState != .Active {
                    LocalNotifications.scheduleNotification(emoji + " " + String(NSDate()) + "\n" + log)
                }
                
                var pending = emoji + " " + String(NSDate()) + "\n----------------------------\n" + log + "\n\n\n"
                if !overwite {
                    pending = pending + contents
                }
                contents = pending
                try pending.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("StoreLogs: Write error.")
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("logUpdated", object: nil, userInfo:["text": contents])
            
            return contents
        }
        return String()
    }
    
}