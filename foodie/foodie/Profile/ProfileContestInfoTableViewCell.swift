//
//  ProfileContestInfoTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-22.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ProfileContestInfoTableViewCell: UITableViewCell {

    let kStackViewPaddingX: CGFloat = 30.0
    let kStackViewPaddingY: CGFloat = 20.0
    let timeLeftLabel = UILabel()
    let endDateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell() {
        if let contest = Contest.shared {
            endDateLabel.text = "on " + FoodieDateFormatter.friendlyStringForDate(date: contest.endTime) + ", 11:59pm EST"
            
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: contest.endTime).day!
            if daysLeft > 0 {
                timeLeftLabel.text = "in \(daysLeft) days"
            } else {
                timeLeftLabel.text = "Today"
            }
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2.0
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = .white
        externalContainerView.applyDefaultShadow()
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(stackView)

        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7.0).isActive = true
        
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: stackView, with: UIEdgeInsets(top: kStackViewPaddingY, left: kStackViewPaddingX, bottom: kStackViewPaddingY, right: kStackViewPaddingX))
        
        let title = UILabel()
        title.font = UIFont(font: .helveticaNeue, size: 15)
        title.text = "The current giveaway round ends:"
        title.textColor = UIColor.cc74MediumGrey
        
        timeLeftLabel.font = UIFont(font: .helveticaNeueBold, size: 15)
        timeLeftLabel.textColor = UIColor.cc74MediumGrey
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        endDateLabel.font = UIFont(font: .helveticaNeue, size: 15)
        endDateLabel.textColor = UIColor.cc74MediumGrey
        
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(timeLeftLabel)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(endDateLabel)
        
    }
}
