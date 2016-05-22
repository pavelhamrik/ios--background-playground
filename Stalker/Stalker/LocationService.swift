//
//  LocationService.swift
//
//
//  Created by Anak Mirasing on 5/18/2558 BE.
//
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    class var sharedInstance: LocationService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: LocationService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationService()
        }
        return Static.instance!
    }
    
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            // you have 2 choice
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 200 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func setDistanceFilter(distance: Double) {
        self.locationManager?.distanceFilter = distance
    }
    
    func setAllowsBackgroundLocationUpdates(allowed: Bool) {
        self.locationManager?.allowsBackgroundLocationUpdates = allowed
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        Helpers.storeLogs(String(NSDate()) + "\nStarting Location Updates\n\n", overwite: false)
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stopping Location Updates")
        Helpers.storeLogs(String(NSDate()) + "\nStopping Location Updates\n\n", overwite: false)
        self.locationManager?.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        print("Starting Significant Location Changes Monitoring")
        Helpers.storeLogs(String(NSDate()) + "\nStarting Significant Location Changes Monitoring\n\n", overwite: false)
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        print("Stopping Significant Location Changes Monitoring")
        Helpers.storeLogs(String(NSDate()) + "\nStopping Significant Location Changes Monitoring\n\n", overwite: false)
        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    func initUpdatingLocation() {
        Helpers.storeLogs(String(NSDate()) + "\nApp Initializing\n\n", overwite: false)
        if Helpers.getDefaultString("locationMode") == "Vague Mode" {
            self.startMonitoringSignificantLocationChanges()
        }
        else {
            self.startUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last location
        self.lastLocation = location
        
        // use for real time update location
        updateLocation(location)
        
        let storedLocation = Helpers.getDefaultCLLocation("lastLocation")
        let update = String(self.lastLocation!.timestamp)
            + "\nlat: " + String(self.lastLocation!.coordinate.latitude)
            + " lon: " + String(self.lastLocation!.coordinate.longitude)
            + "\ndst: " + String(self.lastLocation!.distanceFromLocation(storedLocation))
            + " spd: " + String(self.lastLocation!.speed)
            + "\n\n"
        Helpers.setDefaultLocation("lastLocation", location: self.lastLocation!)
        print(update)
        let text = Helpers.storeLogs(update, overwite: false)
        
        NSNotificationCenter.defaultCenter().postNotificationName("locationUpdated", object: nil, userInfo:["text": text])
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        // do on error
        updateLocationDidFailWithError(error)
    }
    
    // Private function
    private func updateLocation(currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error)
    }
}