//
//  ProfileSummaryTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ProfileSummaryTableViewCell: UITableViewCell {
    
    var profileModel: Profile?
    
    lazy var nameLabel = UILabel()
    lazy var numberOfDishesLabel = UILabel()
    lazy var numberOfPointsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(profileModel: Profile) {
        self.profileModel = profileModel
        
        nameLabel.text = profileModel.name
        numberOfDishesLabel.text = "\(profileModel.submissions.count)"
        numberOfPointsLabel.text = "\(profileModel.points)"
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24.0).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        nameLabel.text = "You"
        
        let defaultLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(font: .helveticaNeue, size: 18)!,
            .foregroundColor: UIColor.cc74MediumGrey,
            .kern: -0.5
        ]
        
        numberOfDishesLabel.translatesAutoresizingMaskIntoConstraints = false
        let numberOfDishesAttributedString = NSMutableAttributedString(string: "0 dishes added", attributes: defaultLabelAttributes)
        numberOfDishesAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 18)!, range: NSRange(location: 0, length: 1))
        numberOfDishesLabel.attributedText = numberOfDishesAttributedString
        
        numberOfPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        let numberOfPointsAttributedString = NSMutableAttributedString(string: "0 points", attributes: defaultLabelAttributes)
        numberOfPointsAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 28)!, range: NSRange(location: 0, length: 1))
        numberOfPointsLabel.attributedText = numberOfPointsAttributedString
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(numberOfDishesLabel)
        stackView.addArrangedSubview(numberOfPointsLabel)
    }
}
