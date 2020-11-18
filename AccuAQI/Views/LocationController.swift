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
    var res: [[String: Any]] = []
    
    var KEY_1: String = "7067EF70-F434-4E9A-81AB-493611F975AA"
    var source1: String = "https://www.airnowapi.org/aq/forecast/latLong/?format=application/json&distance=25&"
    // DarkSky API
    var source2: String = ""
    
    // Labels
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aqiReadingLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    // Source 1
    var aqi1: Int = 0
    var lat1: Double = 0.0
    var long1: Double = 0.0
    var desc1: String = ""
    var num1: Int = 0
    var loc1: CLLocation?
    
    // Source 2
    var aqi2: Int = 0
    var lat2: Double = 0.0
    var long2: Double = 0.0
    var loc2: CLLocation?
    
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
            let data = Data(res.utf8)
            if let json = try? (JSONSerialization.jsonObject(with: data, options: []) as! [AnyObject]) {
                self.aqi1 = (json[0]["AQI"] as! Int)
                self.lat1 = (json[0]["Latitude"] as! Double)
                self.long1 = (json[0]["Longitude"] as! Double)
                self.loc1 = CLLocation(latitude: self.lat1, longitude: self.lat2)
                self.num1 = ((json[0]["Category"]!!) as! NSDictionary)["Number"] as! Int
                self.desc1 = ((json[0]["Category"]!!) as! NSDictionary)["Name"] as! String
            }
            DispatchQueue.main.async {
                self.estimateAQI()
                self.updateDescription()
            }
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?,
                                                                  _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    func getAQIReadings(completion: @escaping (String) -> ()) {
        source1 = source1 + "date=\(getDate())&latitude=\(lat)&longitude=\(long)&API_KEY=\(KEY_1)"
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
        // Current location of user
        let markedLocation = CLLocation(latitude: self.lat, longitude: self.long)
        // Calculates distance between the user's location and the API's marked location
        let dist1 = markedLocation.distance(from: loc1!)
        let dist2 = markedLocation.distance(from: loc2!)
        let combined = dist1 + dist2
        
        // Weight for each AQI value
        var w1: Double = 0.0
        var w2: Double = 0.0
        
        // Weights scale with how far away from the target the user is
        w1 = dist2 / combined
        w2 = dist1 / combined
        
        self.aqi = Int((Double(aqi1) * w1) + (Double(aqi2) * w2)) // Weighted average formula
        self.desc = num1
    }
    
    // Given AQI reading, update the text to reflect current state
    func updateDescription() {
        self.aqiReadingLabel.text = "\(aqi)"
        
        // Updates description
        switch (self.desc) {
        case 1:
            self.conditionLabel.text = "Air quality is satisfactory"
        case 2:
            self.conditionLabel.text = "Acceptable air quality, ok for the general public"
        case 3:
            self.conditionLabel.text = "Unhealthy for sensitive groups"
        case 4:
            self.conditionLabel.text = "Unhealthy for the general public"
        case 5:
            self.conditionLabel.text = "Health Alert: Risks of health effect"
        case 6:
            self.conditionLabel.text = "Emergency Conditions: Affects everyone"
        default:
            self.conditionLabel.text = "Not available"
        }
        
        // After the estimation for the AQI is made: it is updated onto the screen
        self.aqiReadingLabel.text = "\(aqi)"
    }
    
    func getDate() -> String {
        let dF = DateFormatter()
        dF.dateFormat = "yyyy-MM-dd"
        return dF.string(from: Date())
    }
}

extension Double {
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }
}
