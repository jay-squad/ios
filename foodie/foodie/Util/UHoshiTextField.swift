//
//  UHoshiTextField.swift
//  foodie
//
//  Created by Austin Du on 2018-06-28.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import TextFieldEffects

extension HoshiTextField {
    func defaultStyle() {
        placeholderColor = .cc200LightGrey
        textColor = .cc45DarkGrey
        placeholderFontScale = 0.85
        borderInactiveColor = .cc155Grey
        borderActiveColor = .cc45DarkGrey
        font = UIFont(font: .helveticaNeue, size: 18.0)
    }
    
    func errorStyle() {
        defaultStyle()
        borderActiveColor = .ccErrorRed
        borderInactiveColor = .ccErrorRed
    }
}
