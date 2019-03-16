//
//  FoodieEmptyStateTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-15.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

let kFoodieEmptyStateTableViewCellId = "FoodieEmptyStateTableViewCellId"

class FoodieEmptyStateTableViewCell: UITableViewCell {

    let titleLabel = UILabel()
    let friendlyImageView = UIImageView()

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
    
    func configureCell(text: String, imageString: String) {
        titleLabel.text = text
        friendlyImageView.image = UIImage(named: imageString)
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(externalContainerView)
        contentView.applyAutoLayoutInsetsForAllMargins(to: externalContainerView, with: .zero)
        

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(font: .avenirBook, size: 14)
        titleLabel.textColor = .cc155Grey
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        friendlyImageView.translatesAutoresizingMaskIntoConstraints = false
        friendlyImageView.contentMode = .scaleAspectFit
        friendlyImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        
        externalContainerView.addSubview(stackView)
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: stackView, with: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30))
        
        stackView.addArrangedSubview(friendlyImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(UIView())
    }
}
