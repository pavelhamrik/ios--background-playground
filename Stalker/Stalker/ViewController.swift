//
//  ViewController.swift
//  Stalker
//
//  Created by Pavel Hamrik on 22/05/16.
//  Copyright © 2016 Pavel Hamrik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let locationManager = LocationService.sharedInstance
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var clearLogsButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // erase the placeholder
        textView.text = ""
        
        clearLogsButton.layer.cornerRadius = 2
        switchModeButton.layer.cornerRadius = 2
        
        if Helpers.getDefaultString("locationMode") == "Vague Mode" {
            switchModeButton.setTitle("Vague Mode", forState: UIControlState.Normal)
        }
        else if Helpers.getDefaultString("locationMode") == "Precise Mode" {
            switchModeButton.setTitle("Precise Mode", forState: UIControlState.Normal)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTextView(_:)), name:"locationUpdated", object: nil)
    }
    
    func updateTextView(notification: NSNotification) {
        let userinfo = notification.userInfo
        if userinfo?["text"] != nil {
            textView.text = userinfo?["text"] as! String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Memory Warning")
    }
    
    @IBAction func clearLogs(sender: UIButton) {
        textView.text = Helpers.storeLogs(String(NSDate()) + "\nLogs Cleared", overwite: true)
    }
    
    @IBAction func switchMode(sender: UIButton) {
        if Helpers.getDefaultString("locationMode") == "Vague Mode" {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
            Helpers.setDefault("locationMode", value: "Precise Mode")
            switchModeButton.setTitle("Precise Mode", forState: UIControlState.Normal)
        }
        else {
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            Helpers.setDefault("locationMode", value: "Vague Mode")
            switchModeButton.setTitle("Vague Mode", forState: UIControlState.Normal)
        }
    }

}

