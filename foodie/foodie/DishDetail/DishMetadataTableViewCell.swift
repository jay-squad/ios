//
//  DishMetadataTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-07.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class DishMetadataTableViewCell: UITableViewCell {

    var dish: Dish?
    
    let lastUpdatedLabel = UILabel()

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
        if let date = dish?.itemMetadata.updatedAt {
            lastUpdatedLabel.text = "updated \(DateFormatter.friendlyStringForDate(date: date))"
        }
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = CommonMargins.metadataStackViewSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5,
                                                       left: CommonMargins.metadataStackViewHorizonalMargin,
                                                       bottom: 8,
                                                       right: CommonMargins.metadataStackViewHorizonalMargin)
        
        contentView.addSubview(stackView)
        contentView.applyAutoLayoutInsetsForAllMargins(to: stackView, with: .zero)
        
        lastUpdatedLabel.font = UIFont(font: .helveticaOblique, size: 12)
        lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints = false
        lastUpdatedLabel.textColor = UIColor.cc200LightGrey
        
        stackView.addArrangedSubview(lastUpdatedLabel)
    }

}
