//
//  UUIString.swift
//  foodie
//
//  Created by Austin Du on 2018-07-05.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
