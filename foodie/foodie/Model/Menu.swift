//
//  Menu.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation

class Menu {

    var displayOption: RestaurantDetailDisplayOption = .grid

    init() {

    }
}

class MenuSection {

    var dishes: [Dish] = []

    init() {

    }

    init(dishes: [Dish]) {
        self.dishes = dishes
    }
}
