//
//  InfoViewController.swift
//  AccuAQI
//
//  Created by Jin Kim on 12/8/20.
//

import UIKit

class InfoViewController: UIViewController {
    
    // UIButton to see more
    @IBOutlet weak var source: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sourceClicked(_ sender: Any) {
        if let url = URL(string: "https://www.airnow.gov/aqi/aqi-basics/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
