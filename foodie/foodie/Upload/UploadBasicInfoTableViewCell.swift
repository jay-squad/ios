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

protocol UploadBasicInfoTableViewCellDelegate: class {
    func onDishSectionDropDownShouldShow() -> Bool
}

class UploadBasicInfoTableViewCell: FormComponentTableViewCell {
    
    let dishSectionTextField = HoshiTextField()
    let dishSectionDropDown = DropDown()
    let dishTextField = SearchTextField()
    let priceTextField = HoshiTextField()
    
    weak var delegate: UploadBasicInfoTableViewCellDelegate?
    
    var isPreviousSelectedDishSectionCustom: Bool = false
    var amountTypedString: String = ""
    var priceFloat: Float = 0 {
        didSet {
            formComponentDelegate?.onPriceFloatUpdated(priceFloat)
        }
    }
    
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
            dishSectionDropDown.dataSource = menu.sections.map({ $0.name })
            dishTextField.filterStrings(menu.flatDishList)
        } else {
            dishSectionDropDown.dataSource = []
            dishTextField.filterStrings([])
        }
        if dishSectionDropDown.dataSource.count == 0 {
            dishSectionDropDown.dataSource.append(kNoSection)
        }
        dishSectionDropDown.dataSource.append("+ Add a Menu Section")
    }
    
    func configureCell(menu: Menu?, prefilledSubmission: Submission) {
        configureCell(menu: menu)
        
        dishTextField.text = prefilledSubmission.dish?.name
        formComponentDelegate?.onTextFieldUpdated(dishTextField)
        dishSectionTextField.text = prefilledSubmission.dish?.section
        formComponentDelegate?.onTextFieldUpdated(dishSectionTextField)
        if let price = prefilledSubmission.dish?.price {
            priceFloat = price
            priceTextField.text = "$ \(price)"
            amountTypedString = "\(price)".replacingOccurrences(of: ".", with: "")
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
        dishSectionTextField.tag = UploadFormStringComponent.dishSection.rawValue
        dishSectionTextField.autocorrectionType = .no
        dishSectionTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDishSectionTextFieldTapped(_:))))
        dishSectionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        dishSectionSelectView.addSubview(dishSectionTextField)
        
        DropDown.appearance().backgroundColor = UIColor.white
        dishSectionDropDown.anchorView = dishSectionTextField
        dishSectionDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == self.dishSectionDropDown.dataSource.count - 1 {
                self.dishSectionDropDown.hide()
                if !self.isPreviousSelectedDishSectionCustom {
                    self.dishSectionTextField.text = ""
                    self.formComponentDelegate?.onTextFieldUpdated(self.dishSectionTextField)
                }
                self.dishSectionTextField.becomeFirstResponder()
                self.isPreviousSelectedDishSectionCustom = true
            } else {
                self.dishSectionTextField.text = item
                self.formComponentDelegate?.onTextFieldUpdated(self.dishSectionTextField)
                self.isPreviousSelectedDishSectionCustom = false
            }
        }
        
        dishTextField.translatesAutoresizingMaskIntoConstraints = false
        dishTextField.itemSelectionHandler = { searchItems, itemPosition in
            self.dishTextField.text = searchItems[itemPosition].title
            self.formComponentDelegate?.onTextFieldUpdated(self.dishTextField)
            self.dishTextField.resignFirstResponder()
        }
        dishTextField.defaultStyle()
        dishTextField.placeholder = "Dish Name"
        dishTextField.tag = UploadFormStringComponent.dishName.rawValue
        dishTextField.autocorrectionType = .no
        dishTextField.theme.font = dishTextField.theme.font.withSize(14)
        dishTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        dishSelectView.addSubview(dishTextField)
        
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.defaultStyle()
        priceTextField.placeholder = "Price"
        priceTextField.delegate = self
        priceTextField.keyboardType = .numberPad
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
        let shouldShow = delegate?.onDishSectionDropDownShouldShow() ?? true
        if shouldShow {
            dishSectionDropDown.show()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        formComponentDelegate?.onTextFieldUpdated(textField)
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
        textField.validate()
        return false
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        amountTypedString = ""
        return true
    }
    
}
