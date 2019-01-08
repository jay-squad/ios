//
//  RestaurantDetailMenuListTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-18.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit

class RestaurantDetailMenuListTableViewCell: UITableViewCell {

    weak var dish: Dish?
    var nameLabel = UILabel()
    var priceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(dish: Dish?) {
        guard let dish = dish else { return }
        self.dish = dish
        nameLabel.text = dish.name
        priceLabel.text = String(format: "$ %.2f", dish.price)
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        nameLabel.textColor = UIColor.cc45DarkGrey
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.textAlignment = .right
        priceLabel.font = UIFont(font: .helveticaNeue, size: 14)
        priceLabel.textColor = UIColor.cc45DarkGrey
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(nameLabel)
        externalContainerView.addSubview(priceLabel)
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        externalContainerView.heightAnchor.constraint(equalToConstant: 46.0).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 24.0).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: externalContainerView.centerYAnchor).isActive = true
        
        priceLabel.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor,
                                             constant: -24.0).isActive = true
        priceLabel.centerYAnchor.constraint(equalTo: externalContainerView.centerYAnchor).isActive = true
    }

}
