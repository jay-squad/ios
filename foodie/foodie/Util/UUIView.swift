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
}
