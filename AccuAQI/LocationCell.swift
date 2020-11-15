//
//  LocationCell.swift
//  AccuAQI
//
//  Created by Jin Kim on 11/6/20.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    func configure(_ city: String) {
        // Setting Labels to update recording information
        locationLabel.text = "\(city)"
        locationLabel.textColor = UIColor.black
        
        // Fitting the text to the labels
        locationLabel.sizeToFit()
        
        // Styling the card
        cardView.backgroundColor = UIColor.white
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = self.frame.size.height / 4
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // space out users in list
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
