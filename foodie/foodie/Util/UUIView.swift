//
//  UUIView.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func applyDefaultShadow() {
        layer.shadowColor = UIColor.cc200LightGrey.withAlphaComponent(0.5).cgColor
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
    }
    
    func applyAutoLayoutInsetsForAllMargins(to view: UIView, with margins: UIEdgeInsets) {
        topAnchor.constraint(equalTo: view.topAnchor, constant: -margins.top).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -margins.left).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margins.right).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margins.bottom).isActive = true
    }
}
