//
//  HomeTabController.swift
//  AccuAQI
//
//  Created by Jin Kim on 11/10/20.
//

import UIKit
import CoreLocation

class ViewController: UITabBarController, UITabBarControllerDelegate, CLLocationManagerDelegate {
    
    // GPS services
    private let locationManager: CLLocationManager = CLLocationManager()
    private var long: Double = 0.0
    private var lat: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        getLocationPermission()
    }
    
    func getLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.long = locValue.longitude
        self.lat = locValue.latitude
        print("Current Location: \(locValue.latitude) \(locValue.longitude)")
    }
    
}

