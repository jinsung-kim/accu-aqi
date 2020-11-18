//
//  LocationController.swift
//  AccuAQI
//
//  Created by Jin Kim on 11/12/20.
//

import UIKit
import CoreLocation

class LocationController: UIViewController {
    
    var long: Double = 0.0
    var lat: Double = 0.0
    var place: String = ""
    var aqi: Int = -1 // In this current state, not a valid number
    
    // Description for current conditions
    var desc: Int = -1
    
    var KEY_1: String = "7067EF70-F434-4E9A-81AB-493611F975AA"
    var source1: String = "https://www.airnowapi.org/aq/forecast/latLong/?format=application/json&distance=25&"
    // DarkSky API
    var source2: String = ""
    
    // Labels
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aqiReadingLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Error handling -> If persistent container fails
        if (self.long == 0.0 && self.lat == 0.0) {
            getCoordinateFrom(address: self.place) { coordinate, error in
                guard let coordinate = coordinate, error == nil else { return }
                self.long = coordinate.longitude
                self.lat = coordinate.latitude
                // Add fetch stuff here with API keys
                self.updateLabels()
            }
        } else {
            updateLabels()
        }
    }
    
    func updateLabels() {
        self.locationLabel.text = self.place
        // Required to get gov API results
        lat = lat.truncate(places: 4)
        long = long.truncate(places: 4)
        getAQIReadings() { res in
            print(res)
        }
        estimateAQI()
        updateDescription()
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    func getAQIReadings(completion: @escaping (String) -> ()) {
        source1 = source1 + "date=\(getDate())&latitude=\(lat)&longitude=\(long)&API_KEY=\(KEY_1)"
//        print(source1)
        let url1 = URL(string: source1)!
        let task1 = URLSession.shared.dataTask(with: url1, completionHandler: { (data, res, err) in
            if (err != nil) {
                print(err!)
                completion("")
            } else {
                if let ret = String(data: data!, encoding: .utf8) {
                    completion(ret)
                } else {
                    completion("")
                }
            }
        })
        task1.resume()
    }
    
    // Makes adjustments to the AQI given the location of the user
    func estimateAQI() {
        
    }
    
    // Given AQI reading, update the text to reflect current state
    func updateDescription() {
        self.aqiReadingLabel.text = "\(aqi)"
        if (self.desc == -1) {
            self.conditionLabel.text = "Not available"
        }
    }
    
    func getDate() -> String {
        let dF = DateFormatter()
        dF.dateFormat = "yyyy-MM-dd"
        return dF.string(from: Date())
    }
}

extension Double {
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
