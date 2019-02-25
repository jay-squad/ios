//
//  ProfileDishSubmissionTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class ProfileDishSubmissionTableViewCell: UITableViewCell {
    
    let kTitleFontSize: CGFloat = 18
    let kDefaultFontSize: CGFloat = 14
    let kDefaultPadding: CGFloat = 16
    let kMaximumLineHeight: CGFloat = 16
    let kCellHeight: CGFloat = 170
    let kImageWidth: CGFloat = 120
    let dishDescriptionParagraphStyle = NSMutableParagraphStyle()
    
    lazy var dishImageView = UIImageView()
    lazy var dishNameLabel = UILabel()
    lazy var dishRestaurantLabel = UILabel()
    lazy var dishPriceLabel = UILabel()
    lazy var dishDescriptionLabel = UILabel()
    lazy var dishApprovalStatusLabel = UILabel()

    var profileDish: Dish?
    var restaurant: Restaurant?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }

    func configureCell(profileDish: Dish?) {
        if let profileDish = profileDish {
            self.profileDish = profileDish
            dishNameLabel.text = profileDish.name
            
            self.dishRestaurantLabel.text = " "
            // grab restaurant data
            NetworkManager.shared.getRestaurant(restaurantId: profileDish.restaurantId) { (json, _, _) in
                if let restaurantJSON = json {
                    self.restaurant = Restaurant(json: restaurantJSON)
                    DispatchQueue.main.async {
                        self.dishRestaurantLabel.text = self.restaurant?.name
                    }
                }
            }

            dishPriceLabel.text = String(format: "$ %.2f", profileDish.price)
            
            let descriptionLabelAttributedString = NSMutableAttributedString(string: profileDish.description,
                                                                             attributes: [.paragraphStyle: dishDescriptionParagraphStyle,
                                                                                          .kern: -0.5])
            dishDescriptionLabel.attributedText = descriptionLabelAttributedString
            
//            setDishApprovalStatusLabel(status: profileDish.approvalStatus)

            if let imageUrl = profileDish.dishImage?.image {
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

        dishNameLabel.font = UIFont(font: .helveticaNeueBold, size: kTitleFontSize)
        dishNameLabel.textColor = .cc45DarkGrey
        dishRestaurantLabel.font = UIFont(font: .helveticaNeue, size: kDefaultFontSize)
        dishRestaurantLabel.textColor = .cc45DarkGrey
        dishPriceLabel.font = UIFont(font: .helveticaNeue, size: kDefaultFontSize)
        dishPriceLabel.textColor = .cc45DarkGrey
        dishDescriptionLabel.font = UIFont(font: .avenirBook, size: kDefaultFontSize)
        dishDescriptionLabel.textColor = .ccGreyishBrown
        dishDescriptionLabel.numberOfLines = 3
        dishDescriptionParagraphStyle.lineSpacing = 0
        dishDescriptionParagraphStyle.maximumLineHeight = kMaximumLineHeight
        dishApprovalStatusLabel.font = UIFont(font: .helveticaNeue, size: kDefaultFontSize)

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
        horizontalStackView.heightAnchor.constraint(equalToConstant: kCellHeight).isActive = true

        horizontalStackView.addArrangedSubview(dishImageView)
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.widthAnchor.constraint(equalToConstant: kImageWidth).isActive = true

        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.layoutMargins = UIEdgeInsets(top: kDefaultPadding, left: kDefaultPadding, bottom: kDefaultPadding, right: kDefaultPadding)
        verticalStackView.isLayoutMarginsRelativeArrangement = true
        verticalStackView.spacing = 4.0

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
