//
//  ProfileNeedsAuthTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-30.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileNeedsAuthTableViewCell: UITableViewCell {

    let externalContainerView = UIView()
    
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
        label.text = "Log in to upload dishes and earn rewards!"
        label.font = UIFont(font: .helveticaNeueBold, size: 18.0)
        label.textColor = .cc45DarkGrey
        label.numberOfLines = 0
        label.textAlignment = .center
        
        externalContainerView.addSubview(label)
        
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        label.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 40).isActive = true
        label.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: 50).isActive = true
        label.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor, constant: -40).isActive = true
        
        let imageView = UIImageView(image: UIImage(named: "login_img"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        externalContainerView.addSubview(imageView)
        
        label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -30).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        imageView.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        
        let loginButton = FacebookButton()
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        externalContainerView.addSubview(loginButton)
        loginButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 70).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        
        let legalLabel = FacebookButton.getLegalLabel()
        externalContainerView.addSubview(legalLabel)
        legalLabel.translatesAutoresizingMaskIntoConstraints = false
        legalLabel.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -20).isActive = true
        legalLabel.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        legalLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
    }
}
