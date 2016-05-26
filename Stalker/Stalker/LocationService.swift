//
//  LocationService.swift
//  https://github.com/igroomgrim/CLLocationManager-Singleton-in-Swift/blob/master/LocationService.swift
//
//  Created by Anak Mirasing on 5/18/2558 BE.
//  Modified by Pavel Hamrik on 26/05/16.
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
        
        // The accuracy of the location data
        // kCLLocationAccuracyBestForNavigation // even more precise, but will juice the battery
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // The minimum distance in meters a device must move horizontally before an update event is generated
        locationManager.distanceFilter = 200
        
        locationManager.delegate = self
    }
    
    func setDistanceFilter(distance: Double) {
        Helpers.storeLogs("LocationService:\nSetting distance filter to \(distance) meters.", emoji: "\u{1F30D}")
        self.locationManager?.distanceFilter = distance
    }
    
    func setAllowsBackgroundLocationUpdates(allowed: Bool) {
        Helpers.storeLogs("LocationService:\nSetting background location updates.", emoji: "\u{1F30D}")
        self.locationManager?.allowsBackgroundLocationUpdates = allowed
    }
    
    func startUpdatingLocation() {
        Helpers.storeLogs("LocationService:\nStarting location updates.\nThe app will not be relaunched if terminated!", emoji: "\u{1F30D}")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        Helpers.storeLogs("LocationService:\nStopping location updates.", emoji: "\u{1F30D}")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        Helpers.storeLogs("LocationService:\nStarting significant location changes monitoring.\nThe app will be relaunched if terminated.", emoji: "\u{1F30D}")
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        Helpers.storeLogs("LocationService:\nStopping significant location changes monitoring.", emoji: "\u{1F30D}")
        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    func initUpdatingLocation() {
        Helpers.storeLogs("LocationService:\nInitializing updating location.", emoji: "\u{1F30D}")
        
        // allow background updates
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
        
        Helpers.storeLogs(update, emoji: "\u{1F4CD}", notify: true)
        
        // use for real time update location
        updateLocation(location)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // TODO: Test the error parsing
        var output = "LocationService:\nUpdate did fail with error.\n"
        output = output + error.localizedDescription + "\n"
        if error.localizedFailureReason != nil {
            output = output + error.localizedFailureReason! + "\n"
        }
        if error.localizedRecoverySuggestion != nil {
            output = output + error.localizedRecoverySuggestion! + "\n"
        }
        Helpers.storeLogs(output, emoji: "\u{2B55}")
        
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