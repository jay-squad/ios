//
//  Restaurant.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation

class Restaurant {
    var name: String
    var cuisine: [String]
    var priceRange: [Int]
    var description: String?
    var medals: [RestaurantMedal] = []
    var website: String?
    var phoneNum: Int?
    
    init(name: String,
         cuisine: [String],
         priceRange: [Int],
         description: String? = nil,
         medals: [RestaurantMedal] = [],
         website: String? = nil,
         phoneNum: Int? = nil) {
        self.name = name
        self.cuisine = cuisine
        self.priceRange = priceRange
        self.description = description
        self.medals = medals
        self.website = website
        self.phoneNum = phoneNum
    }
}
