//
//  RestaurantDetailDisplayOptionsTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-17.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit

protocol RestaurantDetailDisplayOptionsTableViewCellDelegate: class {
    func onDisplayOptionChanged(type: RestaurantDetailDisplayOption)
}

enum RestaurantDetailDisplayOption: Int {
    case grid = 0
    case list = 1
    case expanded = 2
}

class RestaurantDetailDisplayOptionsTableViewCell: UITableViewCell {

    var gridViewButton: UIButton!
    var listViewButton: UIButton!
    var expandedViewButton: UIButton!

    weak var delegate: RestaurantDetailDisplayOptionsTableViewCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(type: RestaurantDetailDisplayOption) {
        switch type {
        case .grid:
            gridViewButton.isSelected = true
        case .list:
            listViewButton.isSelected = true
        case .expanded:
            expandedViewButton.isSelected = true
        }
    }

    private func buildComponents() {
        selectionStyle = .none
        
        gridViewButton = UIButton()
        listViewButton = UIButton()
        expandedViewButton = UIButton()

        gridViewButton.setImage(UIImage(named: "btn_grid_view_selected"), for: .selected)
        gridViewButton.setImage(UIImage(named: "btn_grid_view_unselected"), for: .normal)
        listViewButton.setImage(UIImage(named: "btn_list_view_selected"), for: .selected)
        listViewButton.setImage(UIImage(named: "btn_list_view_unselected"), for: .normal)
        expandedViewButton.setImage(UIImage(named: "btn_expanded_view_selected"), for: .selected)
        expandedViewButton.setImage(UIImage(named: "btn_expanded_view_unselected"), for: .normal)

        gridViewButton.addTarget(self, action: #selector(self.onGridViewButtonTapped(_:)), for: .touchUpInside)
        listViewButton.addTarget(self, action: #selector(self.onListViewButtonTapped(_:)), for: .touchUpInside)
        expandedViewButton.addTarget(self, action: #selector(self.onExpandedViewButtonTapped(_:)), for: .touchUpInside)

        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal

        externalContainerView.addSubview(stackView)
        contentView.addSubview(externalContainerView)

        stackView.addArrangedSubview(gridViewButton)
        stackView.addArrangedSubview(listViewButton)
        stackView.addArrangedSubview(expandedViewButton)

        externalContainerView.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        stackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true

        gridViewButton.widthAnchor.constraint(equalTo: listViewButton.widthAnchor).isActive = true
        gridViewButton.widthAnchor.constraint(equalTo: expandedViewButton.widthAnchor).isActive = true
    }

    @objc private func onGridViewButtonTapped(_ sender: UIButton) {
        gridViewButton.isSelected = true
        listViewButton.isSelected = false
        expandedViewButton.isSelected = false
        delegate?.onDisplayOptionChanged(type: .grid)
    }

    @objc private func onListViewButtonTapped(_ sender: UIButton) {
        gridViewButton.isSelected = false
        listViewButton.isSelected = true
        expandedViewButton.isSelected = false
        delegate?.onDisplayOptionChanged(type: .list)
    }

    @objc private func onExpandedViewButtonTapped(_ sender: UIButton) {
        gridViewButton.isSelected = false
        listViewButton.isSelected = false
        expandedViewButton.isSelected = true
        delegate?.onDisplayOptionChanged(type: .expanded)
    }

}
