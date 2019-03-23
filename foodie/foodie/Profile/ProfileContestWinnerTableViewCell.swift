//
//  ProfileContestTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

protocol ProfileContestWinnerTableViewCellDelegate: class {
    func onRequestAmazonCodeTapped()
}

class ProfileContestWinnerTableViewCell: FormComponentTableViewCell {
    
    let kShowCodeString = "claim Amazon gift code"
    
    private let amazonButton = UIButton()
    
    var profile: Profile?
    weak var delegate: ProfileContestWinnerTableViewCellDelegate?
    
    func configureCell(profile: Profile) {
        self.profile = profile
    }
    
    override func buildComponents() {
        super.buildComponents()
        selectionStyle = .none
        
        setCellHeader(title: "Winner!", subtitle: "You are one of the winners of our giveaway.\nClaim your reward now!*")
        titleLabel.textColor = .ccMoneyGreen
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        
        let noticeLabel = UILabel()
        noticeLabel.numberOfLines = 0
        noticeLabel.text = "*Your reward will be available to claim for one week."
        noticeLabel.font = UIFont(font: .avenirMedium, size: 12)
        
        amazonButton.translatesAutoresizingMaskIntoConstraints = false
        amazonButton.layer.borderColor = UIColor.cc45DarkGrey.cgColor
        amazonButton.layer.borderWidth = 1.0
        amazonButton.layer.cornerRadius = 8.0
        amazonButton.setTitle(kShowCodeString, for: .normal)
        amazonButton.setTitleColor(UIColor.cc45DarkGrey, for: .normal)
        amazonButton.titleLabel?.font = UIFont(font: .helveticaNeueBold, size: 16.0)
        amazonButton.addTarget(self, action: #selector(onAmazonButtonTapped(_:)), for: .touchUpInside)
        amazonButton.titleLabel?.numberOfLines = 0
        amazonButton.titleLabel?.textAlignment = .center
        amazonButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        amazonButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        customViewContainer.addSubview(stackView)
        
        stackView.addArrangedSubview(amazonButton)
        stackView.addArrangedSubview(noticeLabel)
        stackView.applyAutoLayoutInsetsForAllMargins(to: customViewContainer, with: .zero)
    }
    
    @objc private func onAmazonButtonTapped(_ sender: UIButton) {
        guard let profile = profile else { return }
        
        if sender.titleLabel?.text == kShowCodeString {
            delegate?.onRequestAmazonCodeTapped()
        } else {
            sender.setTitle(kShowCodeString, for: .normal)
        }
    }
    
    func showAmazonCode() {
        guard let profile = profile else { return }
        amazonButton.setTitle(profile.amazonCode, for: .normal)
    }
}
