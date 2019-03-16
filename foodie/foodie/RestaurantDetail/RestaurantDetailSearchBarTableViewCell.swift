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
        searchBar.placeholder = "search dishes in restaurant"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.barTintColor = .white
        searchBar.tintColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.isTranslucent = false
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.cc74MediumGrey
        searchBar.subviews[0].subviews.compactMap { $0 as? UITextField }.first?.tintColor = UIColor.ccOchre
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = UIColor.cc240SuperLightGrey
        
        externalContainerView.addSubview(searchBar)
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: searchBar, with: UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0))
        
        contentView.addSubview(externalContainerView)
        contentView.applyAutoLayoutInsetsForAllMargins(to: externalContainerView, with: .zero)
    }

}
