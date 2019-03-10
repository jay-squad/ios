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
import DropDown

class UploadBasicInfoTableViewCell: FormComponentTableViewCell {
    
    let dishSectionTextField = HoshiTextField()
    let dishSectionDropDown = DropDown()
    let dishTextField = SearchTextField()
    let priceTextField = HoshiTextField()
    
    var isPreviousSelectedDishSectionCustom: Bool = false
    var amountTypedString: String = ""
    var priceFloat: Float = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addValidationRules()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addValidationRules()
    }
    
    func configureCell(menu: Menu?) {
        if let menu = menu {
            dishSectionDropDown.dataSource = menu.sections.map({ $0.name ?? "" })
            dishSectionDropDown.dataSource.append("+ Add a Menu Section")
            
            dishTextField.filterStrings(menu.flatDishList)
        }
    }
    
//    func configureCell(restaurantResult: ValidationResult?,
//                       dishResult: ValidationResult?,
//                       priceResult: ValidationResult?) {
//        if let result = restaurantResult, !result.isValid {
//            dishSectionTextField.errorStyle()
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
        
        let dishSectionSelectView = UIView()
        let dishSelectView = UIView()
        let priceView = UIView()
        dishSectionSelectView.translatesAutoresizingMaskIntoConstraints = false
        dishSelectView.translatesAutoresizingMaskIntoConstraints = false
        priceView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(dishSectionSelectView)
        stackView.addArrangedSubview(dishSelectView)
        stackView.addArrangedSubview(priceView)
        customViewContainer.addSubview(stackView)
        
        dishSectionTextField.translatesAutoresizingMaskIntoConstraints = false
        dishSectionTextField.defaultStyle()
        dishSectionTextField.placeholder = "Dish Section in Menu"
        dishSectionTextField.tag = UploadFormComponent.restaurant.rawValue
        dishSectionTextField.autocorrectionType = .no
        dishSectionTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDishSectionTextFieldTapped(_:))))
        dishSectionSelectView.addSubview(dishSectionTextField)
        
        DropDown.appearance().backgroundColor = UIColor.white
        dishSectionDropDown.anchorView = dishSectionTextField
        dishSectionDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == self.dishSectionDropDown.dataSource.count - 1 {
                self.dishSectionDropDown.hide()
                if !self.isPreviousSelectedDishSectionCustom {
                    self.dishSectionTextField.text = ""
                }
                self.dishSectionTextField.becomeFirstResponder()
                self.isPreviousSelectedDishSectionCustom = true
            } else {
                self.dishSectionTextField.text = item
                self.isPreviousSelectedDishSectionCustom = false
            }
        }
        
        dishTextField.translatesAutoresizingMaskIntoConstraints = false
        dishTextField.defaultStyle()
        dishTextField.placeholder = "Dish Name"
        dishTextField.tag = UploadFormComponent.dish.rawValue
        dishTextField.autocorrectionType = .no
        dishTextField.theme.font = dishTextField.theme.font.withSize(14)
        dishSelectView.addSubview(dishTextField)
        
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.defaultStyle()
        priceTextField.placeholder = "Price"
        priceTextField.delegate = self
        priceTextField.keyboardType = .numberPad
        priceTextField.tag = UploadFormComponent.price.rawValue
        priceTextField.autocorrectionType = .no
        priceView.addSubview(priceTextField)
        
        dishSectionSelectView.topAnchor.constraint(equalTo: dishSectionTextField.topAnchor).isActive = true
        dishSectionSelectView.leadingAnchor.constraint(equalTo: dishSectionTextField.leadingAnchor).isActive = true
        dishSectionSelectView.trailingAnchor.constraint(equalTo: dishSectionTextField.trailingAnchor).isActive = true
        dishSectionSelectView.bottomAnchor.constraint(equalTo: dishSectionTextField.bottomAnchor).isActive = true
        
        dishSelectView.topAnchor.constraint(equalTo: dishTextField.topAnchor).isActive = true
        dishSelectView.leadingAnchor.constraint(equalTo: dishTextField.leadingAnchor).isActive = true
        dishSelectView.trailingAnchor.constraint(equalTo: dishTextField.trailingAnchor).isActive = true
        dishSelectView.bottomAnchor.constraint(equalTo: dishTextField.bottomAnchor).isActive = true
        
        priceView.topAnchor.constraint(equalTo: priceTextField.topAnchor).isActive = true
        priceView.leadingAnchor.constraint(equalTo: priceTextField.leadingAnchor).isActive = true
        priceView.bottomAnchor.constraint(equalTo: priceTextField.bottomAnchor).isActive = true
        priceTextField.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        
        dishSectionTextField.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        dishTextField.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        priceTextField.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        
        // boilerplate
        stackView.applyAutoLayoutInsetsForAllMargins(to: customViewContainer, with: .zero)
    }
    
    private func addValidationRules() {
        var requiredRules = ValidationRuleSet<String>()
        requiredRules.add(rule: Validator.requiredRule)
        
        var priceRules = ValidationRuleSet<String>()
        priceRules.add(rule: Validator.priceRule)
        
        dishSectionTextField.validationRules = requiredRules
        dishTextField.validationRules = requiredRules
        priceTextField.validationRules = priceRules
        
        dishSectionTextField.validationHandler = { result in
            switch result {
            case .valid:
                self.dishSectionTextField.defaultStyle()
            case .invalid(_):
                self.dishSectionTextField.errorStyle()
            }
        }
        dishSectionTextField.validateOnInputChange(enabled: true)
        
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
    
    @objc private func onDishSectionTextFieldTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        dishSectionDropDown.show()
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
            priceFloat = decNumber.floatValue
            textField.text = newString
        } else {
            amountTypedString = String(amountTypedString.dropLast())
            if amountTypedString.count > 0 {
                let decNumber = NSDecimalNumber(string: amountTypedString).multiplying(by: 0.01)
                let newString = "$ " +  formatter.string(from: decNumber)!
                priceFloat = decNumber.floatValue
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
