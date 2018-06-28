//
//  RestaurantDetailMenuExpandedTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-18.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import SDWebImage
import UIFontComplete

class RestaurantDetailMenuExpandedTableViewCell: UITableViewCell {

    let dishImageView = UIImageView()
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let descriptionLabel = UILabel()
    let tagsLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(dish: Dish?) {
        guard let dish = dish else { return }
        nameLabel.text = dish.name
        priceLabel.text = "$ \(dish.price)"
        descriptionLabel.text = dish.description
        if let imageUrl = dish.image {
            dishImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.cc253UltraLightGrey
        
        let externalContainerView = UIView()
        externalContainerView.backgroundColor = .white
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.applyDefaultShadow()
        
        let externalStackView = UIStackView()
        externalStackView.translatesAutoresizingMaskIntoConstraints = false
        externalStackView.axis = .vertical
        
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.clipsToBounds = true
        
        let metadataStackView = UIStackView()
        metadataStackView.translatesAutoresizingMaskIntoConstraints = false
        metadataStackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        metadataStackView.isLayoutMarginsRelativeArrangement = true
        metadataStackView.spacing = 3.0

        metadataStackView.axis = .vertical
        
        let nameAndPriceStackView = UIStackView()
        nameAndPriceStackView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        nameLabel.textColor = UIColor.cc45DarkGrey
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont(font: .helveticaNeue, size: 14)
        priceLabel.textColor = UIColor.cc45DarkGrey
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont(font: .avenirBook, size: 14)
        descriptionLabel.textColor = UIColor.ccGreyishBrown
        
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(externalStackView)
        
        externalStackView.addArrangedSubview(dishImageView)
        externalStackView.addArrangedSubview(metadataStackView)
        
        metadataStackView.addArrangedSubview(nameAndPriceStackView)
        metadataStackView.addArrangedSubview(descriptionLabel)
        metadataStackView.addArrangedSubview(UIView())
//        metadataStackView.addArrangedSubview(tagsLabel)
        
        nameAndPriceStackView.addArrangedSubview(nameLabel)
        nameAndPriceStackView.addArrangedSubview(priceLabel)
        nameAndPriceStackView.axis = .vertical
        nameAndPriceStackView.spacing = 0
        
        nameAndPriceStackView.heightAnchor.constraint(equalToConstant: 39.0).isActive = true
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                   constant: 5.0).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                       constant: 5.0).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                        constant: -5.0).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                      constant: -5.0).isActive = true
        
        externalStackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        externalStackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor).isActive = true
        externalStackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor).isActive = true
        externalStackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
        
        dishImageView.widthAnchor.constraint(equalTo: dishImageView.heightAnchor).isActive = true

        // if we want fixed height for the data panel
//        metadataStackView.heightAnchor.constraint(equalToConstant: 125.0).isActive = true
    }

}
