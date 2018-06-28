//
//  UploadAdditionalInfoTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects

class UploadAdditionalInfoTableViewCell: UploadFormComponentTableViewCell {
    
    var additionalNotesView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func buildComponents() {
        super.buildComponents()
        
        setCellHeader(title: "Additional Notes",
                      subtitle: "Let us know if you’ve changed anything about your dish from its original form.")
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24.0
        
        additionalNotesView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(additionalNotesView)
        customViewContainer.addSubview(stackView)
        
        let additionalNotesTextField = HoshiTextField()
        additionalNotesTextField.translatesAutoresizingMaskIntoConstraints = false
        additionalNotesTextField.defaultStyle()
        additionalNotesTextField.placeholder = "e.g. extra rice, salad instead of fries"
        additionalNotesTextField.tag = UploadFormComponent.notes.rawValue
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

}
