//
//  AdditionalInfoTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects

class AdditionalInfoTableViewCell: FormComponentTableViewCell {
    
    var additionalNotesView = UIView()
    let additionalNotesTextField = HoshiTextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(title: String, subtitle: String, placeholder: String, prefilledDescription: String?) {
        setCellHeader(title: title,
                      subtitle: subtitle)
        additionalNotesTextField.placeholder = placeholder
        if let prefilledDescription = prefilledDescription, prefilledDescription != "" {
            additionalNotesTextField.text = prefilledDescription
        }
    }
    
    override func buildComponents() {
        super.buildComponents()
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24.0
        
        additionalNotesView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(additionalNotesView)
        customViewContainer.addSubview(stackView)
        
        additionalNotesTextField.translatesAutoresizingMaskIntoConstraints = false
        additionalNotesTextField.defaultStyle()
        additionalNotesTextField.tag = UploadFormComponent.dishDescription.rawValue
        additionalNotesTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        additionalNotesView.addSubview(additionalNotesTextField)

        additionalNotesView.topAnchor.constraint(equalTo: additionalNotesTextField.topAnchor).isActive = true
        additionalNotesView.leadingAnchor.constraint(equalTo: additionalNotesTextField.leadingAnchor).isActive = true
        additionalNotesView.trailingAnchor.constraint(equalTo: additionalNotesTextField.trailingAnchor).isActive = true
        additionalNotesView.bottomAnchor.constraint(equalTo: additionalNotesTextField.bottomAnchor).isActive = true

        additionalNotesTextField.heightAnchor.constraint(equalToConstant: kTextFieldHeight).isActive = true
        
        // boilerplate
        stackView.topAnchor.constraint(equalTo: customViewContainer.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: customViewContainer.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: customViewContainer.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: customViewContainer.bottomAnchor).isActive = true
    }

    
    @objc func textFieldDidChange(_ textField: UITextField) {
        formComponentDelegate?.onTextFieldUpdated(textField)
    }
}
