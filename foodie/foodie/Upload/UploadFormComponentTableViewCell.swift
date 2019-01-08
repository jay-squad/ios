//
//  UploadFormComponentTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects

enum UploadFormComponent: Int {
    case restaurant
    case dish
    case price
    case notes
}

class UploadFormComponentTableViewCell: UITableViewCell {

    let kTextFieldHeight: CGFloat = 50.0
    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    
    var customViewContainer = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func setCellHeader(title: String?, subtitle: String?) {
        if let title = title {
            titleLabel.text = title
        }
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
        }
    }
    
    func buildComponents() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.cc253UltraLightGrey
        clipsToBounds = true
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = .white
        externalContainerView.applyDefaultShadow()
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20.0
        
        let titleStackView = UIStackView()
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.spacing = 3.0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont(font: .helveticaNeue, size: 14)
        subtitleLabel.numberOfLines = 0
        customViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(stackView)
        stackView.addArrangedSubview(titleStackView)
        stackView.addArrangedSubview(customViewContainer)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7.0).isActive = true
        
        stackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: 20.0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 30.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor,
                                            constant: -30.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -45.0).isActive = true
    }
}
