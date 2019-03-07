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
    
    lazy var expandedView = RestaurantDetailMenuExpandedView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(dish: Dish?) {
        expandedView.configureView(dish: dish)
    }
    
    func addShadow() {
        expandedView.addShadow()
    }
    
    private func buildComponents() {
        selectionStyle = .none
        expandedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expandedView)
        contentView.applyAutoLayoutInsetsForAllMargins(to: expandedView, with: .zero)
    }

}
