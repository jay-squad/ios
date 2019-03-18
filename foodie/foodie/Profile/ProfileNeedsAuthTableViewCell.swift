//
//  ProfileNeedsAuthTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-30.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import FBSDKLoginKit

protocol ProfileNeedsAuthTableViewCellDelegate: class {
    func showMoreMenuActionSheet()
}

class ProfileNeedsAuthTableViewCell: UITableViewCell {

    let externalContainerView = UIView()
    weak var delegate: ProfileNeedsAuthTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(navigationBar: UINavigationBar?, tabBar: UITabBar?) {
        if let navigationBar = navigationBar, let tabBar = tabBar {
            externalContainerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - (navigationBar.isHidden ? 0 : navigationBar.frame.size.height) - tabBar.frame.size.height).isActive = true
        } else {
            // arbitrary
            externalContainerView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(externalContainerView)
        
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: contentView, with: .zero)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Log in to upload dishes, earn points, and contribute to Foodie!"
        label.font = UIFont(font: .avenirHeavy, size: 18.0)
        label.textColor = .cc45DarkGrey
        label.numberOfLines = 0
        label.textAlignment = .center
        
        externalContainerView.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 40).isActive = true
        label.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: 50).isActive = true
        label.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor, constant: -40).isActive = true
        
        let legalLabel = FacebookButton.getLegalLabel()
        externalContainerView.addSubview(legalLabel)
        legalLabel.translatesAutoresizingMaskIntoConstraints = false
        legalLabel.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -50).isActive = true
        legalLabel.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        legalLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
        
        let loginButton = FacebookButton()
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        externalContainerView.addSubview(loginButton)
        loginButton.bottomAnchor.constraint(equalTo: legalLabel.topAnchor, constant: -30).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        
        let spacer1 = UIView()
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        let spacer2 = UIView()
        spacer2.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(named: "bao"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [spacer1, imageView, spacer2])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        spacer1.heightAnchor.constraint(equalTo: spacer2.heightAnchor).isActive = true
        
        externalContainerView.addSubview(stackView)
        label.bottomAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        stackView.bottomAnchor.constraint(equalTo: loginButton.topAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        
        let moreMenuButton = UIButton(type: .infoLight)
        externalContainerView.addSubview(moreMenuButton)
        moreMenuButton.translatesAutoresizingMaskIntoConstraints = false
        moreMenuButton.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor, constant: -5).isActive = true
        moreMenuButton.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: 5).isActive = true
        moreMenuButton.addTarget(self, action: #selector(onMoreMenuButtonTapped), for: .touchUpInside)
    }
    
    @objc private func onMoreMenuButtonTapped() {
        delegate?.showMoreMenuActionSheet()
    }
}
