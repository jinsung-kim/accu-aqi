//
//  LocationController.swift
//  AccuAQI
//
//  Created by Jin Kim on 11/12/20.
//

import UIKit

class LocationController: UIViewController {
    
    var long: Double = 0.0
    var lat: Double = 0.0
    var place: String = ""
    
    // Labels
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aqiReadingLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add fetch stuff here with API keys
        
    }
    
    func updateLabels() {
        
    }
}
