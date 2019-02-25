//
//  MapRestaurantModalView.swift
//  foodie
//
//  Created by Austin Du on 2019-02-25.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class MapRestaurantModalView: UIView {

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let addressLabel = UILabel()
    
    let snapshot = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildComponents()
    }
    
    private func buildComponents() {
        backgroundColor = UIColor.cc253UltraLightGrey
        applyDefaultShadow()
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(externalContainerView)
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: self, with: .zero)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.cc74MediumGrey
        titleLabel.font = UIFont(font: .helveticaNeueBold, size: 18.0)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = UIColor.cc74MediumGrey
        descriptionLabel.font = UIFont(font: .helveticaNeue, size: 14.0)
        
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.textColor = UIColor.cc155Grey
        addressLabel.font = UIFont(font: .helveticaNeue, size: 14.0)
        
        snapshot.translatesAutoresizingMaskIntoConstraints = false
        snapshot.contentMode = .scaleAspectFill
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(addressLabel)
//        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(snapshot)
                
        externalContainerView.addSubview(stackView)
        
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: stackView, with: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
    
    func configureView(title: String?, description: String?, address: String?) {
        titleLabel.text = title
        descriptionLabel.text = description
        addressLabel.text = address
    }
    
    func configureImage(image: UIImage?) {
        snapshot.image = image
    }
    
}
