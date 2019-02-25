//
//  Profile.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class Profile {
    var id: Int
    var name: String
    var points: Int
    var metadata: Metadata
    
    var submissions: [Submission] = []
    
    init(json: JSON) {
        id = json["id"].int ?? -1
        name = json["name"].string ?? ""
        points = json["points"].int ?? -1
        metadata = Metadata(json: json)
        
        var submittedDishes: [Dish] = []
        var submittedDishImages: [DishImage] = []
        var submittedMenuSections: [MenuSection] = []
        var submittedRestaurants: [Restaurant] = []
        
        for restaurantJSON in json["submitted_restaurants"].array ?? [] {
            let restaurant = Restaurant(json: restaurantJSON)
            submittedRestaurants.append(restaurant)
        }
        
        var rank = 0
        for menuSectionJSON in json["submitted_menu_sections"].array ?? [] {
            let menuSection = MenuSection(json: menuSectionJSON, rank: rank)
            submittedMenuSections.append(menuSection)
            rank += 1
        }
        
        for itemJSON in json["submitted_items"].array ?? [] {
            let item = Dish(json: itemJSON)
            submittedDishes.append(item)
        }
        
        for itemImageJSON in json["submitted_item_images"].array ?? [] {
            let itemImage = DishImage(json: itemImageJSON)
            submittedDishImages.append(itemImage)
        }
    }
}
