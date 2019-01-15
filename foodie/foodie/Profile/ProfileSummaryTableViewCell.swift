//
//  ProfileSummaryTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ProfileSummaryTableViewCell: UITableViewCell {

    let defaultLabelAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(font: .helveticaNeue, size: 18)!,
        .foregroundColor: UIColor.cc74MediumGrey,
        .kern: -0.5
    ]

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
        setNumberOfDishesLabel(numberOfDishes: profileModel.submissions.count)
        setNumberOfPointsLabel(numberOfPoints: profileModel.points)
    }

    private func buildComponents() {
        selectionStyle = .none

        contentView.backgroundColor = UIColor.cc253UltraLightGrey

        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.clipsToBounds = false
        externalContainerView.backgroundColor = UIColor.white
        externalContainerView.applyDefaultShadow()

        contentView.addSubview(externalContainerView)
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false

        externalContainerView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 24.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor, constant: -24.0).isActive = true
        stackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: 24.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -24.0).isActive = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        nameLabel.text = "You"

        numberOfDishesLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberOfDishesLabel(numberOfDishes: 0)

        numberOfPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberOfPointsLabel(numberOfPoints: 0)

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(numberOfDishesLabel)
        stackView.addArrangedSubview(numberOfPointsLabel)
    }

    private func setNumberOfDishesLabel(numberOfDishes: Int) {
        let numberOfDishesAttributedString = NSMutableAttributedString(string: "\(numberOfDishes) dishes added", attributes: defaultLabelAttributes)
        numberOfDishesAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 18)!, range: NSRange(location: 0, length: 1))
        numberOfDishesLabel.attributedText = numberOfDishesAttributedString
    }

    private func setNumberOfPointsLabel(numberOfPoints: Int) {
        let numberOfPointsAttributedString = NSMutableAttributedString(string: "\(numberOfPoints) points", attributes: defaultLabelAttributes)
        numberOfPointsAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 28)!, range: NSRange(location: 0, length: 1))
        numberOfPointsLabel.attributedText = numberOfPointsAttributedString
    }
}
