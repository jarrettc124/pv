//
//  LocationManager.swift
//  pozivibes
//
//  Created by Jarrett Chen on 1/27/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import Foundation
import CoreLocation
class LocationManager: NSObject, CLLocationManagerDelegate{
    
    //////////////////////////////////////////////////////////////////////
    // MARK: Properties
    
    var locManager:CLLocationManager!
    var lastLocation:CLLocation?
    var locationCallback:((NSError?,CLLocation?)->Void)?
    
    //////////////////////////////////////////////////////////////////////
    // MARK: Methods
    
    override init() {
        super.init()
        locManager = CLLocationManager()
        locManager.delegate = self

    }
    
    func getAuthorizationStatus(successHandler:((CLAuthorizationStatus)->Void)?,failHandler:((CLAuthorizationStatus)->Void)?){
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            if let successHandler = successHandler{
                successHandler(CLLocationManager.authorizationStatus())
                
            }
            
        }else if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined){
            locManager.requestAlwaysAuthorization()
        }else{
            if let failHandler = failHandler{
                failHandler(CLLocationManager.authorizationStatus())
            }
        }
        
    }
    
    func fetchLocationWithCompletionHandler(handler:(NSError?,CLLocation?)->Void){
        dispatch_async(dispatch_get_main_queue()){
            self.locationCallback=handler
            self.locManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locManager.distanceFilter = kCLDistanceFilterNone
            self.locManager.startUpdatingLocation()
        }
    }
    
    //////////////////////////////////////////////////////////////////////
    // MARK: Class Methods
    class func checkLocationEnabled()->Bool{
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined){
            return false
        }else{
            return true
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////
    // MARK: Location Delegate

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Update location called")
        lastLocation = locations.last
        if let locationCallback = locationCallback{
            locationCallback(nil,lastLocation)
            self.locationCallback=nil
            
        }
        dispatch_async(dispatch_get_main_queue()){
            self.locManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("location \(newLocation)")
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if let locationCallback = locationCallback{
            locationCallback(error,nil)
            self.locationCallback=nil
            dispatch_async(dispatch_get_main_queue()){
                self.locManager.stopUpdatingLocation()
            }
        }
    }

}