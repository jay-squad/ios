//
//  SearchRestaurantTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-07-04.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import SDWebImage

class SearchRestaurantTableViewCell: UITableViewCell {
    
    var nameLabel = UILabel()
    var dishImageViews: [UIImageView] = []
    var verticalStackView = UIStackView()
    var rowStackView1 = UIStackView()
    var rowStackView2 = UIStackView()
    var externalContainerView = UIView()
    var nameLabelToVerticalStackViewTopConstaint: NSLayoutConstraint?
    
    var searchResult: SearchResult?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        buildComponents()
    }
    
    func configureCell(searchResult: SearchResult?) {
        if let searchResult = searchResult {
            self.searchResult = searchResult
            guard let restaurant = searchResult.restaurant else { return }
            
            buildComponents()
            
            nameLabel.text = restaurant.name
            if searchResult.restaurantImages.count == 0 {
                verticalStackView.removeFromSuperview()
                nameLabelToVerticalStackViewTopConstaint?.isActive = false
                nameLabel.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
            } else if searchResult.restaurantImages.count < 4 {
                verticalStackView.removeArrangedSubview(rowStackView2)
            }
            for i in 0..<searchResult.restaurantImages.count {
                dishImageViews[i].image = nil
                if let urlString = searchResult.restaurantImages[i] {
                    dishImageViews[i].sd_setImage(with: URL(string: urlString))
                }
            }
        }
    }
    
    // TODO: Separate out parts that MUST be rerendered on every configureCell call
    private func buildComponents() {
        selectionStyle = .none
        
        externalContainerView.removeFromSuperview()
        
        // TODO: reuse these views instead of reinstantiating
        dishImageViews = []
        nameLabel = UILabel()
        verticalStackView = UIStackView()
        rowStackView1 = UIStackView()
        rowStackView2 = UIStackView()
        externalContainerView = UIView()
        
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = UIColor.cc253UltraLightGrey
        
        for _ in 0..<6 {
            let dishImageView = UIImageView()
            dishImageView.translatesAutoresizingMaskIntoConstraints = false
            dishImageView.contentMode = .scaleAspectFill
            dishImageView.clipsToBounds = true
            dishImageViews.append(dishImageView)
        }
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(font: .helveticaNeueMedium, size: 24.0)
        nameLabel.textColor = UIColor.cc74MediumGrey
        
        contentView.addSubview(externalContainerView)
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4.0
        
        rowStackView1.translatesAutoresizingMaskIntoConstraints = false
        rowStackView1.axis = .horizontal
        rowStackView2.translatesAutoresizingMaskIntoConstraints = false
        rowStackView2.axis = .horizontal
        rowStackView1.spacing = 4.0
        rowStackView2.spacing = 4.0
        
        verticalStackView.addArrangedSubview(rowStackView1)
        
        rowStackView1.addArrangedSubview(dishImageViews[0])
        rowStackView1.addArrangedSubview(dishImageViews[1])
        rowStackView1.addArrangedSubview(dishImageViews[2])
        
        if let searchResult = searchResult, searchResult.restaurantImages.count > 3 {
            verticalStackView.addArrangedSubview(rowStackView2)
            rowStackView2.addArrangedSubview(dishImageViews[3])
            rowStackView2.addArrangedSubview(dishImageViews[4])
            rowStackView2.addArrangedSubview(dishImageViews[5])
        }
        
        externalContainerView.addSubview(nameLabel)
        externalContainerView.addSubview(verticalStackView)
        
        nameLabel.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        nameLabelToVerticalStackViewTopConstaint = nameLabel.bottomAnchor.constraint(
            equalTo: verticalStackView.topAnchor)
        nameLabelToVerticalStackViewTopConstaint!.isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 16.0).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor,
                                            constant: -16.0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        
        let imageSize = (UIScreen.main.bounds.width - 24.0) / 3.0
        for dishImageView in dishImageViews {
            dishImageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        }
        
        verticalStackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor,
                                                   constant: 6).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor,
                                                    constant: -6).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
        
        rowStackView1.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        rowStackView2.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2.0).isActive = true
    }

}
