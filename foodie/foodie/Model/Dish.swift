//
//  Dish.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Dish {
    var name: String = ""
    var image: String?
    var price: Float = 0
    var description: String = ""
    
    init(json: JSON) {
        name = json["name"].string ?? ""
        image = json["image_link"].string
        price = json["price"].float ?? 0
        description = json["description"].string ?? ""
    }
}
