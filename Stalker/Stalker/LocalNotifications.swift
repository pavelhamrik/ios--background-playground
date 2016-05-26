//
//  LocalNotifications.swift
//  Stalker
//
//  Created by Pavel Hamrik on 26/05/16.
//  Copyright © 2016 Pavel Hamrik. All rights reserved.
//

import UIKit
import AVFoundation

class LocalNotifications {

    static func setup() {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    static func scheduleNotification(message: String) {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        if settings.types == .None {
            print("LocalNotifications:\nStalker does not have permission to schedule notifications.")
            return
        }
    
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.alertBody = message
        notification.alertAction = "Go to App"
        notification.hasAction = true
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["originalMessage": message]
        
        // this should be probably handled more gracefully
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func removeAppIconBadge() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

}