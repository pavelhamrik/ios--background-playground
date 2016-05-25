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
        Helpers.storeLogs("LocationService:\nSetting distance filter to \(distance) meters.", overwite: false)
        self.locationManager?.distanceFilter = distance
    }
    
    func setAllowsBackgroundLocationUpdates(allowed: Bool) {
        Helpers.storeLogs("LocationService:\nSetting background location updates.", overwite: false)
        self.locationManager?.allowsBackgroundLocationUpdates = allowed
    }
    
    func startUpdatingLocation() {
        Helpers.storeLogs("LocationService:\nStarting location updates.", overwite: false)
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        Helpers.storeLogs("LocationService:\nStopping location updates.", overwite: false)
        self.locationManager?.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        Helpers.storeLogs("LocationService:\nStarting significant location changes monitoring.", overwite: false)
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        Helpers.storeLogs("LocationService:\nStopping significant location changes monitoring.", overwite: false)
        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    func initUpdatingLocation() {
        Helpers.storeLogs("LocationService:\nInitializing updating location.", overwite: false)
        
        // allow background updates, following the appropriate Info.plist setup
        self.setAllowsBackgroundLocationUpdates(true)
        
        if Helpers.getDefaultString("locationMode") == "Vague Mode" {
            self.locationManager?.startMonitoringSignificantLocationChanges()
        }
        else {
            self.locationManager?.startUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last location
        self.lastLocation = location
        
        let storedLocation = Helpers.getDefaultCLLocation("lastLocation")
        let update = "time: " + String(self.lastLocation!.timestamp)
            + "\nlat: " + String(self.lastLocation!.coordinate.latitude)
            + " lon: " + String(self.lastLocation!.coordinate.longitude)
            + "\ndst: " + String(self.lastLocation!.distanceFromLocation(storedLocation))
            + " spd: " + String(self.lastLocation!.speed)
        Helpers.setDefaultCLLocation("lastLocation", location: self.lastLocation!)
        
        Helpers.storeLogs(update, overwite: false)
        
        // use for real time update location
        updateLocation(location)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        Helpers.storeLogs("LocationService:\nUpdate did fail with error.", overwite: false)
        
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