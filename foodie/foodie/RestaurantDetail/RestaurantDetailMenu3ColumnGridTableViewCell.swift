//
//  RestaurantDetailMenu3ColumnGridTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-18.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import SDWebImage

class RestaurantDetailMenu3ColumnGridTableViewCell: UITableViewCell {
    
    var dish0: Dish?
    var dish1: Dish?
    var dish2: Dish?
    let dish0ImageView = UIImageView()
    let dish1ImageView = UIImageView()
    let dish2ImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(dish0: Dish?, dish1: Dish?, dish2: Dish?) {
        self.dish0 = dish0
        self.dish1 = dish1
        self.dish2 = dish2
        if let imageUrl = dish0?.image {
            dish0ImageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            dish0ImageView.image = nil
        }
        
        if let imageUrl = dish1?.image {
            dish1ImageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            dish1ImageView.image = nil
        }
        
        if let imageUrl = dish2?.image {
            dish2ImageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            dish2ImageView.image = nil
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = UIColor.cc253UltraLightGrey
        
        let dishStackView = UIStackView()
        dishStackView.translatesAutoresizingMaskIntoConstraints = false
        
        dish0ImageView.translatesAutoresizingMaskIntoConstraints = false
        dish1ImageView.translatesAutoresizingMaskIntoConstraints = false
        dish2ImageView.translatesAutoresizingMaskIntoConstraints = false
        dish0ImageView.contentMode = .scaleAspectFill
        dish1ImageView.contentMode = .scaleAspectFill
        dish2ImageView.contentMode = .scaleAspectFill
        dish0ImageView.clipsToBounds = true
        dish1ImageView.clipsToBounds = true
        dish2ImageView.clipsToBounds = true
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(dishStackView)
        dishStackView.addArrangedSubview(dish0ImageView)
        dishStackView.addArrangedSubview(dish1ImageView)
        dishStackView.addArrangedSubview(dish2ImageView)
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
        
        dish0ImageView.widthAnchor.constraint(equalTo: dish1ImageView.widthAnchor).isActive = true
        dish0ImageView.widthAnchor.constraint(equalTo: dish2ImageView.widthAnchor).isActive = true
        dish0ImageView.heightAnchor.constraint(equalTo: dish0ImageView.widthAnchor).isActive = true
        dish1ImageView.heightAnchor.constraint(equalTo: dish0ImageView.widthAnchor).isActive = true
        dish2ImageView.heightAnchor.constraint(equalTo: dish0ImageView.widthAnchor).isActive = true
    }
    
}
