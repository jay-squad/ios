//
//  RestaurantDetailMenu1ColumnGridTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-18.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit

class RestaurantDetailMenu1ColumnGridTableViewCell: UITableViewCell {
    
    let dishImageView = UIImageView()
    var dish: Dish?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(dish: Dish?) {
        self.dish = dish
        if let imageUrl = dish?.dishImage?.image {
            dishImageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            dishImageView.image = nil
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = UIColor.cc253UltraLightGrey
        
        let dishStackView = UIStackView()
        dishStackView.translatesAutoresizingMaskIntoConstraints = false
        
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.clipsToBounds = true
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(dishStackView)
        dishStackView.addArrangedSubview(dishImageView)
        dishStackView.axis = .horizontal
        dishStackView.spacing = 2
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2.0).isActive = true
        
        dishStackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        dishStackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor,
                                               constant: 5.0).isActive = true
        dishStackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor,
                                                constant: -5.0).isActive = true
        dishStackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
        
        dishImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width/3.0).isActive = true
    }

}
