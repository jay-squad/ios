//
//  SearchDishTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-07-04.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import SDWebImage

class SearchDishTableViewCell: UITableViewCell {
    
    var searchResult1: SearchResult?
    var searchResult2: SearchResult?
    
    var viewComponent1 = SearchDishTableViewCellComponent()
    var viewComponent2 = SearchDishTableViewCellComponent()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(searchResult1: SearchResult?, searchResult2: SearchResult?) {
        self.searchResult1 = searchResult1
        self.searchResult2 = searchResult2
        if let searchResult1 = searchResult1, let dish = searchResult1.dish {
            viewComponent1.configureView(dish: dish)
        }
        if let searchResult2 = searchResult2, let dish = searchResult2.dish {
            viewComponent2.configureView(dish: dish)
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = UIColor.cc253UltraLightGrey
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 6.0
        stackView.axis = .horizontal
        
        viewComponent1.translatesAutoresizingMaskIntoConstraints = false
        viewComponent2.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(viewComponent1)
        stackView.addArrangedSubview(viewComponent2)
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(stackView)
        
        viewComponent1.widthAnchor.constraint(equalTo: viewComponent2.widthAnchor).isActive = true
        viewComponent1.heightAnchor.constraint(equalTo: viewComponent2.heightAnchor).isActive = true
        viewComponent1.heightAnchor.constraint(equalTo: viewComponent1.widthAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor,
                                           constant: 6.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor,
                                            constant: -6.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0).isActive = true
    }

}

class SearchDishTableViewCellComponent: UIView {
    
    var dish: Dish?
    
    var dishImageView = UIImageView()
    var dishNameLabel = UILabel()
    var dishPriceLabel = UILabel()
    var gradientView = UIView()
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    func configureView(dish: Dish?) {
        self.dish = dish
        if let dish = dish {
            if let imageUrl = dish.image {
                dishImageView.sd_setImage(with: URL(string: imageUrl))
            }
            dishNameLabel.text = dish.name
            dishPriceLabel.text = String(format: "%.2f", dish.price)
        }
    }
    
    private func buildComponents() {
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        dishNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dishPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2.0
        
        addSubview(dishImageView)
        addSubview(gradientView)
        addSubview(stackView)
        
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.clipsToBounds = true
        
        dishNameLabel.numberOfLines = 2
        dishNameLabel.font = UIFont(font: .helveticaNeueMedium, size: 12.0)
        dishNameLabel.textColor = UIColor.cc253UltraLightGrey
        
        dishPriceLabel.font = UIFont(font: .helveticaNeueBold, size: 12.0)
        dishPriceLabel.textColor = UIColor.cc253UltraLightGrey
        dishPriceLabel.textAlignment = .right
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.cc74MediumGrey.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        stackView.addArrangedSubview(dishNameLabel)
        stackView.addArrangedSubview(dishPriceLabel)
        
        dishImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dishImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        dishImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dishImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        gradientView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        gradientView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        stackView.topAnchor.constraint(equalTo: gradientView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 8.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -8.0).isActive = true
        
        dishPriceLabel.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
    }
}
