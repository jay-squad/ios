//
//  UDKImagePickerController.swift
//  foodie
//
//  Created by Austin Du on 2018-06-28.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import DKImagePickerController

extension DKImagePickerController {
    func setDefaultControllerProperties() {
        singleSelect = true
        assetType = .allPhotos
    }
}
