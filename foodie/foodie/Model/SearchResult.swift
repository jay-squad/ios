//
//  SearchResult.swift
//  foodie
//
//  Created by Austin Du on 2018-07-04.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation

class SearchResult {
    enum ResultType {
        case restaurant
        case dish
    }
    
    var restaurant: Restaurant?
    
    // restaurant
    var restaurantImages: [String?] = []
    
    // dish
    var dish: Dish?
    
    init(dish: Dish?) {
        guard dish != nil else { return }
        
        self.dish = dish
        
        // grab restaurant data
        NetworkManager.shared.getRestaurant(restaurantId: self.dish!.restaurantId) { (json, _, _) in
            if let restaurantJSON = json {
                self.restaurant = Restaurant(json: restaurantJSON)
            }
        }
    }
    
    init(restaurant: Restaurant?, restaurantImages: [String?]) {
        guard restaurant != nil else { return }
        self.restaurantImages = restaurantImages
        self.restaurant = restaurant
    }
}
