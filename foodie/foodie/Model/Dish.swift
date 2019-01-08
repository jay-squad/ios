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
    var dishId: Int
    var name: String = ""
    var image: String?
    var price: Float = 0
    var description: String = ""
    var restaurantId: Int
    
    init(json: JSON) {
        name = json["item"]["normalized_name"].string ?? ""
        image = json["image"]["link"].string
        price = json["item"]["price"].float ?? 0
        description = json["item"]["description"].string ?? ""
        restaurantId = json["item"]["restaurant_id"].int ?? -1
        dishId = json["item"]["id"].int ?? -1
    }
}
