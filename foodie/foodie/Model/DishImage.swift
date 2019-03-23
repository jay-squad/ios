//
//  DishImage.swift
//  foodie
//
//  Created by Austin Du on 2019-02-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class DishImage {
    
    var image: String?
    var imageMetadata: Metadata
    var dishId: Int = -1
    var restaurantId: Int?
    
    var description: String?
    
    init(json: JSON) {
        image = json["link"].string
        imageMetadata = Metadata(json: json)
        dishId = json["menu_item_id"].int ?? -1
        restaurantId = json["restaurant_id"].int
        
        description = json["description"].string
    }
}
