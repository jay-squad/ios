//
//  UValidator.swift
//  foodie
//
//  Created by Austin Du on 2018-06-28.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import Validator

extension Validator {
    static let requiredRule = ValidationRuleLength(min: 1,
                                            lengthType: .characters,
                                            error: UploadFormError.required)
    static let priceRule = ValidationRulePattern(pattern: "^\\$ ?(([1-9]\\d{0,2}(,\\d{3})*)|0)?\\.\\d{1,2}$",
                                                 error: UploadFormError.price)
}
