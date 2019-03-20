//
//  CachedRestaurants.swift
//  foodie
//
//  Created by Austin Du on 2019-03-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation

class CachedRestaurants {
    static let shared: CachedRestaurants = {
        let instance = CachedRestaurants()
        return instance
    }()
    
    var all: [Restaurant] = []
}
