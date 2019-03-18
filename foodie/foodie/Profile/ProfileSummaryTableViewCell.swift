//
//  ProfileSummaryTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class ProfileSummaryTableViewCell: UITableViewCell {

    let defaultLabelAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(font: .helveticaNeue, size: 16)!,
        .foregroundColor: UIColor.cc74MediumGrey,
        .kern: -0.5
    ]

    var profileModel: Profile?

    lazy var profilePicImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var numberOfAcceptedDishesLabel = UILabel()
    lazy var numberOfPendingDishesLabel = UILabel()
    lazy var numberOfRejectedDishesLabel = UILabel()
    lazy var numberOfPointsThisRoundLabel = UILabel()
    lazy var numberOfPointsTotalLabel = UILabel()

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
        
        var acceptedDishes: Int = 0
        var pendingDishes: Int = 0
        var rejectedDishes: Int = 0
        for submission in profileModel.submissions {
            if let status = submission.metadata?.approvalStatus {
                switch status {
                case .approved:
                    acceptedDishes += 1
                case .pending:
                    pendingDishes += 1
                case .rejected:
                    rejectedDishes += 1
                default:
                    break
                }
            }
        }
        setNumberOfAcceptedDishesLabel(numberOfDishes: acceptedDishes)
        setNumberOfPendingDishesLabel(numberOfDishes: pendingDishes)
        setNumberOfRejectedDishesLabel(numberOfDishes: rejectedDishes)
        setNumberOfPointsTotalLabel(numberOfPoints: profileModel.points)
        setNumberOfPointsThisRoundLabel(numberOfPoints: profileModel.points - profileModel.lastRewardsPoints)
        
        if let fbid = FBSDKAccessToken.current()?.userID, let url = URL(string: "https://graph.facebook.com/v3.2/\(fbid)/picture") {
            profilePicImageView.sd_setImage(with: url)
        }
        
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
        stackView.spacing = 2.0

        externalContainerView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 24.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor, constant: -24.0).isActive = true
        stackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: 24.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -24.0).isActive = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        nameLabel.text = "You"

        numberOfAcceptedDishesLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberOfAcceptedDishesLabel(numberOfDishes: -1)
        
        numberOfPendingDishesLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberOfPendingDishesLabel(numberOfDishes: -1)
        
        numberOfRejectedDishesLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberOfRejectedDishesLabel(numberOfDishes: -1)

        numberOfPointsTotalLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberOfPointsTotalLabel(numberOfPoints: -1)
        
        numberOfPointsThisRoundLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberOfPointsThisRoundLabel(numberOfPoints: -1)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true

        profilePicImageView.image = Bundle.main.icon
        profilePicImageView.contentMode = .scaleAspectFill
        profilePicImageView.translatesAutoresizingMaskIntoConstraints = false
        profilePicImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        profilePicImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        let personStackView = UIStackView()
        personStackView.spacing = 15.0
        personStackView.axis = .horizontal
        
        personStackView.addArrangedSubview(profilePicImageView)
        personStackView.addArrangedSubview(nameLabel)
        personStackView.addArrangedSubview(UIView())
        
        stackView.addArrangedSubview(personStackView)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(numberOfAcceptedDishesLabel)
        stackView.addArrangedSubview(numberOfPendingDishesLabel)
        stackView.addArrangedSubview(numberOfRejectedDishesLabel)
        stackView.addArrangedSubview(numberOfPointsTotalLabel)
        stackView.addArrangedSubview(numberOfPointsThisRoundLabel)
    }

    private func setNumberOfAcceptedDishesLabel(numberOfDishes: Int) {
        let counterString = "\(numberOfDishes >= 0 ? "\(numberOfDishes)" : "-")"
        let numberOfDishesAttributedString = NSMutableAttributedString(string: "\(counterString) \(numberOfDishes == 1 ? "dish" : "dishes") approved", attributes: defaultLabelAttributes)
        let range = NSRange(location: 0, length: counterString.count)
        numberOfDishesAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 18)!, range: range)
        
        numberOfAcceptedDishesLabel.attributedText = numberOfDishesAttributedString
        numberOfAcceptedDishesLabel.textColor = .ccMoneyGreen
    }
    
    private func setNumberOfPendingDishesLabel(numberOfDishes: Int) {
        let counterString = "\(numberOfDishes >= 0 ? "\(numberOfDishes)" : "-")"
        let numberOfDishesAttributedString = NSMutableAttributedString(string: "\(counterString) \(numberOfDishes == 1 ? "dish" : "dishes") pending", attributes: defaultLabelAttributes)
        let range = NSRange(location: 0, length: counterString.count)
        numberOfDishesAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 18)!, range: range)

        numberOfPendingDishesLabel.attributedText = numberOfDishesAttributedString
        numberOfPendingDishesLabel.textColor = .ccPendingBlue
    }
    
    private func setNumberOfRejectedDishesLabel(numberOfDishes: Int) {
        let counterString = "\(numberOfDishes >= 0 ? "\(numberOfDishes)" : "-")"
        let numberOfDishesAttributedString = NSMutableAttributedString(string: "\(counterString) \(numberOfDishes == 1 ? "dish" : "dishes") not approved", attributes: defaultLabelAttributes)
        let range = NSRange(location: 0, length: counterString.count)
        numberOfDishesAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 18)!, range: range)

        numberOfRejectedDishesLabel.attributedText = numberOfDishesAttributedString
        numberOfRejectedDishesLabel.textColor = .ccErrorRed
    }

    private func setNumberOfPointsTotalLabel(numberOfPoints: Int) {
        let counterString = "\(numberOfPoints >= 0 ? "\(numberOfPoints)" : "-")"
        let numberOfPointsAttributedString = NSMutableAttributedString(string: "\(counterString) points in total", attributes: defaultLabelAttributes)
        numberOfPointsAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 20)!, range: NSRange(location: 0, length: counterString.count))
        numberOfPointsTotalLabel.attributedText = numberOfPointsAttributedString
    }
    
    private func setNumberOfPointsThisRoundLabel(numberOfPoints: Int) {
        let counterString = "\(numberOfPoints >= 0 ? "\(numberOfPoints)" : "-")"
        let numberOfPointsAttributedString = NSMutableAttributedString(string: "\(counterString) points this round", attributes: defaultLabelAttributes)
        numberOfPointsAttributedString.addAttribute(.font, value: UIFont(font: .helveticaNeueBold, size: 28)!, range: NSRange(location: 0, length: counterString.count))
        numberOfPointsThisRoundLabel.attributedText = numberOfPointsAttributedString
    }
}
