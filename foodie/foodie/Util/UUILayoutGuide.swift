//
//  UUILayoutGuide.swift
//  foodie
//
//  Created by Austin Du on 2019-03-06.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import UIKit

extension UILayoutGuide {
    func applyAutoLayoutInsetsForAllMargins(to layoutGuide: UILayoutGuide, with margins: UIEdgeInsets) {
        topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -margins.top).isActive = true
        leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: -margins.left).isActive = true
        trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: margins.right).isActive = true
        bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: margins.bottom).isActive = true
    }
}
