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
    
    var type: ResultType = .restaurant
    var restaurant: Restaurant?
    
    // restaurant
    var restaurantImages: [String?] = []
    
    // dish
    var dish: Dish?
}
