//
//  DishMetadataTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-07.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

protocol DishMetadataTableViewCellDelegate: class {
    func onRestaurantTapped(restaurant: Restaurant)
}

class DishMetadataTableViewCell: UITableViewCell {

    var dish: Dish?
    var restaurant: Restaurant?
    
    let lastUpdatedLabel = UILabel()
    let restaurantLabelButton = UIButton()
    
    var restaurantTextAttrs = [
        NSAttributedString.Key.font: UIFont(font: .avenirBookOblique, size: 12),
        NSAttributedString.Key.foregroundColor: UIColor.cc45DarkGrey,
        NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]

    weak var delegate: DishMetadataTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildComponents()
    }
    
    func configureCell(_ dish: Dish?) {
        self.dish = dish
        if let date = dish?.itemMetadata.updatedAt {
            lastUpdatedLabel.text = "updated \(DateFormatter.friendlyStringForDate(date: date))"
        }
        
        if let restaurantId = dish?.restaurantId, restaurantId != -1 {
            NetworkManager.shared.getRestaurant(restaurantId: restaurantId) { (json, _, _) in
                if let restaurantJSON = json {
                    self.restaurant = Restaurant(json: restaurantJSON)
                    let restaurantString = NSMutableAttributedString(string: self.restaurant?.name ?? "", attributes: self.restaurantTextAttrs)
                    self.restaurantLabelButton.setAttributedTitle(restaurantString, for: .normal)
                }
            }
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0,
                                                       left: CommonMargins.metadataStackViewHorizonalMargin,
                                                       bottom: 0,
                                                       right: CommonMargins.metadataStackViewHorizonalMargin)
        
        contentView.addSubview(stackView)
        contentView.applyAutoLayoutInsetsForAllMargins(to: stackView, with: .zero)
        
        restaurantLabelButton.translatesAutoresizingMaskIntoConstraints = false
        restaurantLabelButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        restaurantLabelButton.addTarget(self, action: #selector(onRestaurantTapped), for: .touchUpInside)
        
        lastUpdatedLabel.font = UIFont(font: .avenirBookOblique, size: 12)
        lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints = false
        lastUpdatedLabel.textColor = UIColor.cc200LightGrey
        lastUpdatedLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        let buttonStackView = UIStackView()
        buttonStackView.addArrangedSubview(restaurantLabelButton)
        buttonStackView.addArrangedSubview(UIView())
        buttonStackView.axis = .horizontal
        
        stackView.addArrangedSubview(buttonStackView)
        stackView.addArrangedSubview(lastUpdatedLabel)
    }
    
    @objc private func onRestaurantTapped() {
        if let restaurant = restaurant {
            self.delegate?.onRestaurantTapped(restaurant: restaurant)
        }
    }

}
