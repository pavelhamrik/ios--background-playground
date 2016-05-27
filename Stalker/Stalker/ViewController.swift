//
//  ViewController.swift
//  Stalker
//
//  Created by Pavel Hamrik on 22/05/16.
//  Copyright © 2016 Pavel Hamrik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // the LocationService singleton
    let locationManager = LocationService.sharedInstance
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var clearLogsButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // erase the placeholder
        textView.text = ""
        
        // what beautiful buttons we have here
        clearLogsButton.layer.cornerRadius = 2
        switchModeButton.layer.cornerRadius = 2
        
        // and how informative those buttons are
        if Helpers.getDefaultString("locationMode") == "Vague Mode" {
            switchModeButton.setTitle("Vague Mode", forState: UIControlState.Normal)
        }
        else if Helpers.getDefaultString("locationMode") == "Precise Mode" {
            switchModeButton.setTitle("Precise Mode", forState: UIControlState.Normal)
        }
        
        // start observing for the text field update
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTextView(_:)), name:"logUpdated", object: nil)
    }
    
    // update the text view in reaction to a received NSNotification
    func updateTextView(notification: NSNotification) {
        if UIApplication.sharedApplication().applicationState == .Active {
            let userinfo = notification.userInfo
            if userinfo?["text"] != nil {
                textView.text = userinfo?["text"] as! String
            }
        }
    }
    
    // following a button press, the logs will be cleared
    @IBAction func clearLogs(sender: UIButton) {
        Helpers.storeLogs("ViewController:\nClear logs.", overwite: true, emoji: "\u{1F5D1}")
    }
    
    // following a button press, the location update mode will be switched
    @IBAction func switchMode(sender: UIButton) {
        let newTitle = locationManager.switchMode()
        switchModeButton.setTitle(newTitle, forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Helpers.storeLogs("ViewController:\nDid receive memory warning.", notify: true, emoji: "\u{26A0}")
        // Dispose of any resources that can be recreated.
    }

}

