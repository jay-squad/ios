//
//  UploadBasicInfoTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects
import Validator

class UploadBasicInfoTableViewCell: UploadFormComponentTableViewCell {
    
    let restaurantTextField = HoshiTextField()
    let dishTextField = HoshiTextField()
    let priceTextField = HoshiTextField()
    
    var amountTypedString: String = ""
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addValidationRules()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addValidationRules()
    }
    
//    func configureCell(restaurantResult: ValidationResult?,
//                       dishResult: ValidationResult?,
//                       priceResult: ValidationResult?) {
//        if let result = restaurantResult, !result.isValid {
//            restaurantTextField.errorStyle()
//        }
//        if let result = dishResult, !result.isValid {
//            dishTextField.errorStyle()
//        }
//        if let result = priceResult, !result.isValid {
//            priceTextField.errorStyle()
//        }
//    }
    
    override func buildComponents() {
        super.buildComponents()
        
        setCellHeader(title: "Identify your dish", subtitle: "The bare minimum.")
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24.0
        
        let restaurantSelectView = UIView()
        let dishSelectView = UIView()
        let priceView = UIView()
        restaurantSelectView.translatesAutoresizingMaskIntoConstraints = false
        dishSelectView.translatesAutoresizingMaskIntoConstraints = false
        priceView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(restaurantSelectView)
        stackView.addArrangedSubview(dishSelectView)
        stackView.addArrangedSubview(priceView)
        customViewContainer.addSubview(stackView)
        
        restaurantTextField.translatesAutoresizingMaskIntoConstraints = false
        restaurantTextField.defaultStyle()
        restaurantTextField.placeholder = "Restaurant"
        restaurantTextField.tag = UploadFormComponent.restaurant.rawValue
        restaurantTextField.autocorrectionType = .no
        restaurantSelectView.addSubview(restaurantTextField)
        
        dishTextField.translatesAutoresizingMaskIntoConstraints = false
        dishTextField.defaultStyle()
        dishTextField.placeholder = "Dish Name"
        dishTextField.tag = UploadFormComponent.dish.rawValue
        dishTextField.autocorrectionType = .no
        dishSelectView.addSubview(dishTextField)
        
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.defaultStyle()
        priceTextField.placeholder = "Price"
        priceTextField.delegate = self
        priceTextField.keyboardType = .numberPad
        priceTextField.tag = UploadFormComponent.price.rawValue
        priceTextField.autocorrectionType = .no
        priceView.addSubview(priceTextField)
        
        restaurantSelectView.topAnchor.constraint(equalTo: restaurantTextField.topAnchor).isActive = true
        restaurantSelectView.leadingAnchor.constraint(equalTo: restaurantTextField.leadingAnchor).isActive = true
        restaurantSelectView.trailingAnchor.constraint(equalTo: restaurantTextField.trailingAnchor).isActive = true
        restaurantSelectView.bottomAnchor.constraint(equalTo: restaurantTextField.bottomAnchor).isActive = true
        
        dishSelectView.topAnchor.constraint(equalTo: dishTextField.topAnchor).isActive = true
        dishSelectView.leadingAnchor.constraint(equalTo: dishTextField.leadingAnchor).isActive = true
        dishSelectView.trailingAnchor.constraint(equalTo: dishTextField.trailingAnchor).isActive = true
        dishSelectView.bottomAnchor.constraint(equalTo: dishTextField.bottomAnchor).isActive = true
        
        priceView.topAnchor.constraint(equalTo: priceTextField.topAnchor).isActive = true
        priceView.leadingAnchor.constraint(equalTo: priceTextField.leadingAnchor).isActive = true
        priceView.bottomAnchor.constraint(equalTo: priceTextField.bottomAnchor).isActive = true
        priceTextField.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        
        restaurantTextField.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        dishTextField.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        priceTextField.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        
        // boilerplate
        stackView.topAnchor.constraint(equalTo: customViewContainer.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: customViewContainer.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: customViewContainer.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: customViewContainer.bottomAnchor).isActive = true
    }
    
    private func addValidationRules() {
        var requiredRules = ValidationRuleSet<String>()
        requiredRules.add(rule: Validator.requiredRule)
        
        var priceRules = ValidationRuleSet<String>()
        priceRules.add(rule: Validator.priceRule)
        
        restaurantTextField.validationRules = requiredRules
        dishTextField.validationRules = requiredRules
        priceTextField.validationRules = priceRules
        
        restaurantTextField.validationHandler = { result in
            switch result {
            case .valid:
                self.restaurantTextField.defaultStyle()
            case .invalid(_):
                self.restaurantTextField.errorStyle()
            }
        }
        restaurantTextField.validateOnInputChange(enabled: true)
        
        dishTextField.validationHandler = { result in
            switch result {
            case .valid:
                self.dishTextField.defaultStyle()
            case .invalid(_):
                self.dishTextField.errorStyle()
            }
        }
        dishTextField.validateOnInputChange(enabled: true)
        
        priceTextField.validationHandler = { result in
            switch result {
            case .valid:
                self.priceTextField.defaultStyle()
            case .invalid(_):
                self.priceTextField.errorStyle()
            }
        }
        priceTextField.validateOnInputChange(enabled: true)
    }

}

extension UploadBasicInfoTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if string.count > 0 {
            amountTypedString += string
            let decNumber = NSDecimalNumber(string: amountTypedString).multiplying(by: 0.01)
            let newString = "$ " + formatter.string(from: decNumber)!
            textField.text = newString
        } else {
            amountTypedString = String(amountTypedString.dropLast())
            if amountTypedString.count > 0 {
                let decNumber = NSDecimalNumber(string: amountTypedString).multiplying(by: 0.01)
                let newString = "$ " +  formatter.string(from: decNumber)!
                textField.text = newString
            } else {
                textField.text = "$ 0.00"
            }
            
        }
        return false
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        amountTypedString = ""
        return true
    }
    
}
