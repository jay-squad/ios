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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Log in to upload dishes and earn rewards!"
        label.font = UIFont(font: .helveticaNeueBold, size: 18.0)
        label.textColor = .cc45DarkGrey
        label.numberOfLines = 0
        label.textAlignment = .center
        
        contentView.addSubview(label)
        
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        contentView.applyAutoLayoutInsetsForAllMargins(to: label, with: UIEdgeInsets(top: 50, left: 40, bottom: 100, right: 40))
        
        let loginButton = FBSDKLoginButton()
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(loginButton)
        loginButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
}
