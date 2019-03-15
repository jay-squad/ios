//
//  RestaurantDetailSearchBarTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-14.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

protocol RestaurantDetailSearchBarTableViewCellDelegate: class {
    func viewControllerForSearchBar() -> UISearchBarDelegate
}

class RestaurantDetailSearchBarTableViewCell: UITableViewCell {

    var searchBar: UISearchBar = UISearchBar()
    weak var delegate: RestaurantDetailSearchBarTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell() {
        if let vc = delegate?.viewControllerForSearchBar() {
            searchBar.delegate = vc
        }
    }

    private func buildComponents() {
        selectionStyle = .none
        searchBar.placeholder = "Search Dishes in Restaurant"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        contentView.addSubview(searchBar)
        contentView.applyAutoLayoutInsetsForAllMargins(to: searchBar, with: .zero)
    }

}
