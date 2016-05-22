//
//  ViewController.swift
//  Stalker
//
//  Created by Pavel Hamrik on 22/05/16.
//  Copyright © 2016 Pavel Hamrik. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    let logFile = "Logs.log"
    
    let locationManager = CLLocationManager()
    
    // this should really be in a file if the app is shut down, but...
    var lastLocation = CLLocation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set locationManager delegate to self
        locationManager.delegate = self
        
        // request full location auth
        locationManager.requestAlwaysAuthorization()
        
        // move at least a meter to get a distance update
        // locationManager.distanceFilter = 1
        locationManager.startUpdatingLocation()
        
        // allow background updates (following the appropriate Info.plist setup)
        locationManager.allowsBackgroundLocationUpdates = true
        
        // this is the second mode - significant location change updates
        // locationManager.startMonitoringSignificantLocationChanges()
        
        // erase the placeholder
        textView.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Memory Warning")
    }
    
    
    // store the logs in a file and update the textView
    func storeLogs(log: String) {
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(logFile)
            var contents = String()
            
            //reading
            do {
                contents = try String(contentsOfURL: path, encoding: NSUTF8StringEncoding)
                textView.text = log + contents
            }
            catch {
                print("Logs: Read error.")
            }
            
            //writing
            do {
                let pending = log + contents
                try pending.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Logs: Write error.")
            }
        }
    }
    
    // react to a location update
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let update = String(locationManager.location!.timestamp)
            + "\nlat: " + String(locationManager.location!.coordinate.latitude)
            + " lon: " + String(locationManager.location!.coordinate.longitude)
            + "\ndst: " + String(locationManager.location!.distanceFromLocation(lastLocation))
            + " spd: " + String(locationManager.location!.speed)
            + "\n\n"
        lastLocation = locationManager.location!
        print(update)
        storeLogs(update)
        //textView.text = update + textView.text
    }

    // react to a location error
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}

