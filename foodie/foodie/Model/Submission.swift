//
//  Submission.swift
//  foodie
//
//  Created by Austin Du on 2019-02-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class Submission {
    var uuid: String?
    
    var restaurant: Restaurant?
    var menuSection: MenuSection?
    var dish: Dish?
    var dishImage: DishImage?
    var metadata: Metadata?
    
    init(json: JSON?) {
        if let submissionComponents = json?.array {
            for subcomponent in submissionComponents {
                if let subcomponentarray = subcomponent.array, subcomponentarray.count > 0 {
                    let componentKey = subcomponentarray[0]
                    let componentValue = subcomponentarray[1]
                    uuid = componentValue["request_uuid"].string
                    if componentKey == "submitted_items" {
                        dish = Dish(dishJSON: componentValue)
                        metadata = dish?.itemMetadata
                    } else if componentKey == "submitted_item_images" {
                        dishImage = DishImage(json: componentValue)
                        metadata = dishImage?.imageMetadata
                    } else if componentKey == "submitted_menu_sections" {
                        menuSection = MenuSection(json: componentValue)
                        metadata = menuSection?.metadata
                    } else if componentKey == "submitted_restaurants" {
                        restaurant = Restaurant(json: componentValue)
                        metadata = restaurant?.metadata
                    }
                }
            }
        }
    }
    
    func getRestaurantId() -> Int? {
        if let dish = dish {
            return dish.restaurantId
        }
        if let dishImage = dishImage {
            return dishImage.restaurantId
        }
        if let menuSection = menuSection {
            return menuSection.restaurantId
        }
        if let restaurant = restaurant {
            return restaurant.id
        }
        return nil
    }
    
}
