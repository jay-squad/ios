//
//  RestaurantDetailTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit

class RestaurantDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var externalContainerView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var informationStackView: UIStackView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantCuisineLabel: UILabel!
    @IBOutlet weak var restaurantPriceLabel: UILabel!
    @IBOutlet weak var restaurantDescriptionLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var restaurantWebsiteButton: UIButton!
    @IBOutlet weak var restaurantCallButton: UIButton!
    @IBOutlet weak var restaurantMedalsStackView: UIStackView!
    
    private var restaurant: Restaurant?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.externalContainerView.layer.shadowColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0).cgColor
        self.externalContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.externalContainerView.layer.shadowRadius = 8
        self.externalContainerView.layer.shadowOpacity = 0.25
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        self.restaurantNameLabel.text = restaurant.name
        self.restaurantCuisineLabel.text = restaurant.cuisine.joined(separator: ", ")
        self.restaurantPriceLabel.text = "$\(restaurant.priceRange[0]) - $\(restaurant.priceRange[1])"
        self.restaurantDescriptionLabel.text = restaurant.description
        
        for medal in restaurant.medals {
            let medalView = RestaurantDetailMedalView(medal: medal)
            restaurantMedalsStackView.addArrangedSubview(medalView)
        }
    }
    
}
