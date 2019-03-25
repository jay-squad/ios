//
//  SearchResult.swift
//  foodie
//
//  Created by Austin Du on 2018-07-04.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation

class SearchResult {
    enum ResultType: String {
        case restaurant
        case dish
    }
    
    var restaurant: Restaurant?
    
    // restaurant
    var restaurantImages: [String?] = []
    
    // dish
    var dish: Dish?
    
    init(dish: Dish?, restaurant: Restaurant?) {
        guard dish != nil else { return }
        self.dish = dish
        self.restaurant = restaurant
    }
    
    init(restaurant: Restaurant?, restaurantImages: [String?]) {
        guard restaurant != nil else { return }
        self.restaurantImages = restaurantImages
        self.restaurant = restaurant
    }
}
