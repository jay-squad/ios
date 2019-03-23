//
//  UploadRestaurantTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects
import Validator

protocol UploadRestaurantTableViewCellDelegate: class {
    func restaurantExistenceDidChange(restaurant: Restaurant?, orName: String?)
    func newNonExistentNameTyped(name: String?)
    func newExistingRestaurantSelected(restaurant: Restaurant)
}

class UploadRestaurantTableViewCell: FormComponentTableViewCell {

    let restaurantTextfield = SearchTextField()
    weak var delegate: UploadRestaurantTableViewCellDelegate?
    private var restaurant: Restaurant?
    private var shouldSetTextField = true
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addValidationRules()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addValidationRules()
    }
    
    func configureCell(restaurant: Restaurant? = nil) {
        if let restaurant = restaurant {
            self.restaurant = restaurant
            restaurantTextfield.text = restaurant.name
            formComponentDelegate?.onTextFieldUpdated(restaurantTextfield)
        }
        restaurantTextfield.filterStrings(CachedRestaurants.shared.all.map({ $0.name }))
        restaurantTextfield.delegate = self
    }
    
    override func buildComponents() {
        super.buildComponents()
        
        setCellHeader(title: "Restaurant", subtitle: "Select or create your restaurant.")
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24.0
        
        let restaurantView = UIView()
        restaurantView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(restaurantView)
        customViewContainer.addSubview(stackView)
        
        restaurantTextfield.translatesAutoresizingMaskIntoConstraints = false
        restaurantTextfield.itemSelectionHandler = { searchItems, itemPosition in
            if self.shouldSetTextField {
                self.restaurantTextfield.text = searchItems[itemPosition].title
                self.formComponentDelegate?.onTextFieldUpdated(self.restaurantTextfield)
            } else {
                self.shouldSetTextField = true
            }
            self.restaurantTextfield.resignFirstResponder()
        }
        restaurantTextfield.defaultStyle()
        restaurantTextfield.placeholder = "Restaurant Name"
        restaurantTextfield.tag = UploadFormStringComponent.restaurantName.rawValue
        restaurantTextfield.autocorrectionType = .no
        restaurantTextfield.theme.font = restaurantTextfield.theme.font.withSize(14)
        restaurantView.addSubview(restaurantTextfield)
        restaurantView.applyAutoLayoutInsetsForAllMargins(to: restaurantTextfield, with: .zero)
        restaurantTextfield.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        restaurantTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        stackView.applyAutoLayoutInsetsForAllMargins(to: customViewContainer, with: .zero)
    }

    private func addValidationRules() {
        var requiredRules = ValidationRuleSet<String>()
        requiredRules.add(rule: Validator.requiredRule)
        
        restaurantTextfield.validationRules = requiredRules
        
        restaurantTextfield.validationHandler = { result in
            switch result {
            case .valid:
                self.restaurantTextfield.defaultStyle()
            case .invalid(_):
                self.restaurantTextfield.errorStyle()
            }
        }
        restaurantTextfield.validateOnInputChange(enabled: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        formComponentDelegate?.onTextFieldUpdated(textField)
    }
}

extension UploadRestaurantTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        shouldSetTextField = false
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        let prevRestaurant = restaurant
        restaurant = CachedRestaurants.shared.all.first(where: { (restaurant) -> Bool in
            return restaurant.name == textField.text
        })
        if (prevRestaurant != nil && restaurant == nil)
            || (prevRestaurant == nil && restaurant != nil) {
            if restaurant != nil {
                delegate?.restaurantExistenceDidChange(restaurant: restaurant, orName: nil)
            } else {
                delegate?.restaurantExistenceDidChange(restaurant: nil, orName: textField.text)
            }
        } else if restaurant == nil {
            delegate?.newNonExistentNameTyped(name: textField.text)
        } else if restaurant != nil {
            delegate?.newExistingRestaurantSelected(restaurant: restaurant!)
        }
    }
}
