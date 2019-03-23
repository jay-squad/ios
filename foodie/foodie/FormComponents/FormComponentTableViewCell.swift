//
//  FormComponentTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects
import MapKit

protocol FormComponentTableViewCellDelegate: class {
    func onTextFieldUpdated(_ sender: UITextField)
    func onMapUpdated(_ sender: MKMapView)
    func onPriceFloatUpdated(_ price: Float)
}

class FormComponentTableViewCell: UITableViewCell {

    let kStackViewPadding: CGFloat = 30.0
    let kTextFieldHeight: CGFloat = 50.0
    let kContainerStackViewSpacing: CGFloat = 20.0
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    let titleStackView = UIStackView()

    var customViewContainer = UIView()
    var didAlreadyPrefill = false
    
    weak var formComponentDelegate: FormComponentTableViewCellDelegate?
    
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
        stackView.spacing = kContainerStackViewSpacing
        stackView.distribution = .fill
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.spacing = 3.0
        titleStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        titleStackView.setContentHuggingPriority(.required, for: .vertical)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont(font: .helveticaNeue, size: 14)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        customViewContainer.translatesAutoresizingMaskIntoConstraints = false
        customViewContainer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
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
        
        stackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: kContainerStackViewSpacing).isActive = true
        stackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: kStackViewPadding).isActive = true
        stackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor,
                                            constant: -kStackViewPadding).isActive = true
        stackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -45.0).isActive = true
    }
}
