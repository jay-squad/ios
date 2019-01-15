//
//  ProfileDishSubmissionTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ProfileDishSubmissionTableViewCell: UITableViewCell {

    lazy var dishImageView = UIImageView()
    lazy var dishNameLabel = UILabel()
    lazy var dishRestaurantLabel = UILabel()
    lazy var dishPriceLabel = UILabel()
    lazy var dishDescriptionLabel = UILabel()
    lazy var dishApprovalStatusLabel = UILabel()

    var profileDish: ProfileDish?
    var restaurant: Restaurant?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }

    func configureCell(profileDish: ProfileDish?) {
        if let profileDish = profileDish {
            self.profileDish = profileDish
            dishNameLabel.text = profileDish.name

            // grab restaurant data
            NetworkManager.shared.getRestaurant(restaurantId: profileDish.restaurantId) { (json, _, _) in
                if let restaurantJSON = json {
                    self.restaurant = Restaurant(json: restaurantJSON)
                    self.dishRestaurantLabel.text = self.restaurant?.name
                }
            }

            dishPriceLabel.text = String(format: "$ %.2f", profileDish.price)
            dishDescriptionLabel.text = profileDish.description
            setDishApprovalStatusLabel(status: profileDish.approvalStatus)

            if let imageUrl = profileDish.image {
                dishImageView.sd_setImage(with: URL(string: imageUrl))
            } else {
                dishImageView.image = nil
            }
        }
    }

    private func buildComponents() {
        selectionStyle = .none

        contentView.backgroundColor = UIColor.cc253UltraLightGrey
        contentView.clipsToBounds = false

        dishNameLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        dishRestaurantLabel.font = UIFont(font: .helveticaNeue, size: 14)
        dishPriceLabel.font = UIFont(font: .helveticaNeue, size: 14)
        dishDescriptionLabel.font = UIFont(font: .avenirBook, size: 14)
        dishApprovalStatusLabel.font = UIFont(font: .helveticaNeue, size: 14)

        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.clipsToBounds = false
        externalContainerView.backgroundColor = UIColor.white

        contentView.addSubview(externalContainerView)
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.addSubview(horizontalStackView)
        horizontalStackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor).isActive = true
        horizontalStackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        horizontalStackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
        horizontalStackView.heightAnchor.constraint(equalToConstant: 150).isActive = true

        horizontalStackView.addArrangedSubview(dishImageView)
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true

        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false

        verticalStackView.addArrangedSubview(dishNameLabel)
        verticalStackView.addArrangedSubview(dishRestaurantLabel)
        verticalStackView.addArrangedSubview(dishPriceLabel)
        verticalStackView.addArrangedSubview(dishDescriptionLabel)
        verticalStackView.addArrangedSubview(spacer)
        verticalStackView.addArrangedSubview(dishApprovalStatusLabel)

        horizontalStackView.addArrangedSubview(verticalStackView)

    }

    private func setDishApprovalStatusLabel(status: DishApprovalStatus) {
        var labelString = ""
        var labelColour = UIColor.cc74MediumGrey

        switch status {
        case .approved:
            labelString = "approved"
            labelColour = .ccMoneyGreen
        case .notapproved:
            labelString = "not approved"
            labelColour = .ccErrorRed
        case .pending:
            labelString = "pending approval"
            labelColour = .ccPendingBlue
        default:
            break
        }
        dishApprovalStatusLabel.text = labelString
        dishApprovalStatusLabel.textColor = labelColour
    }
}
