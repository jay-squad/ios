//
//  UploadEarningsTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit

class UploadEarningsTableViewCell: UploadFormComponentTableViewCell {

    var earningsLabel = UILabel()
    var pointsEarned: Int = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(points: Int) {
        pointsEarned = points
        earningsLabel.text = "\(pointsEarned > 0 ? "+" : "") \(pointsEarned) points"
        earningsLabel.textColor = pointsEarned > 0 ? UIColor.ccMoneyGreen : UIColor.cc155Grey
    }
    
    override func buildComponents() {
        super.buildComponents()
        
        setCellHeader(title: "Earnings",
                      subtitle: "Your earnings is based on the amount of submissions " +
                                "that already exist for this dish.")
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24.0
        
        earningsLabel.translatesAutoresizingMaskIntoConstraints = false
        earningsLabel.font = UIFont(font: .helveticaNeueBold, size: 18.0)
        
        stackView.addArrangedSubview(earningsLabel)
        customViewContainer.addSubview(stackView)
        
        // boilerplate
        stackView.topAnchor.constraint(equalTo: customViewContainer.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: customViewContainer.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: customViewContainer.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: customViewContainer.bottomAnchor).isActive = true
    }

}
