//
//  RestaurantMedal.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import UIKit

enum RestaurantMedalType: String {
    case highRating = "HIGHLY RATED"
}

class RestaurantMedal {
    var name: String
    var img: UIImage
    var description: String

    init(type: RestaurantMedalType, description: String) {
        self.name = type.rawValue
        self.description = description

        switch type {
        case .highRating:
            self.img = UIImage(named: "img_medal")!
        }
    }
}
