//
//  RestaurantMedal.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import UIKit

class RestaurantMedal {
    var name: String
    var img: UIImage
    var description: String
    
    init(name: String, img: UIImage, description: String) {
        self.name = name
        self.img = img
        self.description = description
    }
}
