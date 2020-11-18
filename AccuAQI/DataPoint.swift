//
//  DataPoint.swift
//  AccuAQI
//
//  Created by Jin Kim on 11/17/20.
//

import Foundation

struct DataPoint: Codable {
    var lat: Double
    var long: Double
    var AQI: Int
    var category: Int
    var desc: String
}
