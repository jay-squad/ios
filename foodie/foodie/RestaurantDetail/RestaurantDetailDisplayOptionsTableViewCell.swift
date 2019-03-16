//
//  RestaurantDetailDisplayOptionsTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-17.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import Crashlytics

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        let shadowView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
        let topShadow = EdgeShadowLayer(forView: shadowView, edge: .Top)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.layer.addSublayer(topShadow)
        shadowView.alpha = 0.25
        shadowView.isUserInteractionEnabled = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal

        externalContainerView.addSubview(stackView)
        externalContainerView.addSubview(shadowView)
        contentView.addSubview(externalContainerView)

        stackView.addArrangedSubview(gridViewButton)
        stackView.addArrangedSubview(listViewButton)
        stackView.addArrangedSubview(expandedViewButton)

        externalContainerView.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        contentView.applyAutoLayoutInsetsForAllMargins(to: externalContainerView, with: .zero)
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: stackView, with: .zero)
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: shadowView, with: .zero)

        gridViewButton.widthAnchor.constraint(equalTo: listViewButton.widthAnchor).isActive = true
        gridViewButton.widthAnchor.constraint(equalTo: expandedViewButton.widthAnchor).isActive = true
    }

    @objc private func onGridViewButtonTapped(_ sender: UIButton) {
        Answers.logContentView(withName: "RestaurantDetail-DisplayOptionsTap", contentType: "restaurant", contentId: nil,
                               customAttributes: ["type": "grid"])
        
        gridViewButton.isSelected = true
        listViewButton.isSelected = false
        expandedViewButton.isSelected = false
        delegate?.onDisplayOptionChanged(type: .grid)
    }

    @objc private func onListViewButtonTapped(_ sender: UIButton) {
        Answers.logContentView(withName: "RestaurantDetail-DisplayOptionsTap", contentType: "restaurant", contentId: nil,
                               customAttributes: ["type": "list"])
        
        gridViewButton.isSelected = false
        listViewButton.isSelected = true
        expandedViewButton.isSelected = false
        delegate?.onDisplayOptionChanged(type: .list)
    }

    @objc private func onExpandedViewButtonTapped(_ sender: UIButton) {
        Answers.logContentView(withName: "RestaurantDetail-DisplayOptionsTap", contentType: "restaurant", contentId: nil,
                               customAttributes: ["type": "expanded"])
        
        gridViewButton.isSelected = false
        listViewButton.isSelected = false
        expandedViewButton.isSelected = true
        delegate?.onDisplayOptionChanged(type: .expanded)
    }

}

public class EdgeShadowLayer: CAGradientLayer {
    
    public enum Edge {
        case Top
        case Left
        case Bottom
        case Right
    }
    
    public init(forView view: UIView,
                edge: Edge = Edge.Top,
                shadowRadius radius: CGFloat = 20.0,
                toColor: UIColor = UIColor.white.withAlphaComponent(0),
                fromColor: UIColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)) {
        super.init()
        self.colors = [fromColor.cgColor, toColor.cgColor]
        self.shadowRadius = radius
        
        let viewFrame = view.frame
        
        switch edge {
        case .Top:
            startPoint = CGPoint(x: 0.5, y: 0.0)
            endPoint = CGPoint(x: 0.5, y: 1.0)
            self.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: shadowRadius)
        case .Bottom:
            startPoint = CGPoint(x: 0.5, y: 1.0)
            endPoint = CGPoint(x: 0.5, y: 0.0)
            self.frame = CGRect(x: 0.0, y: viewFrame.height - shadowRadius, width: viewFrame.width, height: shadowRadius)
        case .Left:
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
            self.frame = CGRect(x: 0.0, y: 0.0, width: shadowRadius, height: viewFrame.height)
        case .Right:
            startPoint = CGPoint(x: 1.0, y: 0.5)
            endPoint = CGPoint(x: 0.0, y: 0.5)
            self.frame = CGRect(x: viewFrame.width - shadowRadius, y: 0.0, width: shadowRadius, height: viewFrame.height)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
