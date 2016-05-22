//
//  Helpers.swift
//  Stalker
//
//  Created by Pavel Hamrik on 22/05/16.
//  Copyright © 2016 Pavel Hamrik. All rights reserved.
//

import Foundation
import CoreLocation


class Helpers {
    
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    static let logFile = "Logs.log"

    static func setDefault(key: String, value: AnyObject) {
        defaults.setObject(value, forKey: key)
    }
    
    static func setDefaultLocation(key: String, location: CLLocation) {
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

    // store the logs in a file and update the textView
    static func storeLogs(log: String, overwite: Bool) -> String {
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(logFile)
            var contents = String()
            
            // reading
            do {
                contents = try String(contentsOfURL: path, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Logs: Read error.")
            }
            
            // writing
            do {
                var pending = log
                if !overwite {
                    pending = pending + contents
                    contents = pending
                }
                try pending.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Logs: Write error.")
            }
            
            return contents
        }
        return String()
    }
    
}