//
//  ProfileViewModel.swift
//  foodie
//
//  Created by Austin Du on 2019-01-15.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProfileDishSubmissionsViewModel {
    var sectionedDishes: [[ProfileDish]] = [[]]
    
    init(json: JSON, mock: Bool = false) {
        var dishes: [ProfileDish] = []
        if let submissionsJSON = json.array {
            for submissionJSON in submissionsJSON {
                dishes.append(ProfileDish(json: submissionJSON))
            }
        }
        
        if mock {
            dishes = mockProfileDishes()
        }
        
        dishes.sort { return $0.date! < $1.date! }
        
        for dish in dishes {
            if sectionedDishes.last!.isEmpty || Calendar.current.isDate(dish.date!, inSameDayAs: sectionedDishes.last![0].date!) {
                sectionedDishes[sectionedDishes.count-1].append(dish)
            } else {
                sectionedDishes.append([dish])
            }
        }
        
    }
    
    private func mockProfileDishes() -> [ProfileDish] {
        let json1: JSON = [
            "item": [
                "normalized_name": "Miso Ramen",
                "name": "Miso Ramen",
                "price": 7.95,
                "description": "Features a broth made with special miso tare (Japanese soy bean paste). Topped with roasted pork, menma, beansprouts, scallions, nori.",
                "restaurant_id": 71,
                "id": 83
            ],
            "image": [
                "link": "https://s3.us-east-2.amazonaws.com/foodie-prod-menu-item-images/admin/b5d1e85a-0587-4719-b682-90d60f67c1e1.png",
                "menu_item_id": 83,
                "restaurant_id": 71
            ],
            "profile": [
                "date": "2019-01-01T00:00:00",
                "status": 2
            ]
        ]
        let json2: JSON = [
            "item": [
                "normalized_name": "Black Tonkotsu Ramen",
                "name": "Black Tonkotsu Ramen",
                "price": 12.95,
                "description": "Hakata style pork bone soup with blackened garlic oil and tonkotsu toppings.",
                "restaurant_id": 71,
                "id": 86
            ],
            "image": [
                "link": "https://s3.us-east-2.amazonaws.com/foodie-prod-menu-item-images/admin/c1c8a4e0-98d8-4b4f-8b2b-417499617cf6.png",
                "menu_item_id": 86,
                "restaurant_id": 71
            ],
            "profile": [
                "date": "2019-01-02T00:00:00",
                "status": 1
            ]
        ]
        let json3: JSON = [
            "item": [
                "normalized_name": "Black Tonkotsu Ramen",
                "name": "Black Tonkotsu Ramen",
                "price": 12.95,
                "description": "Hakata style pork bone soup with blackened garlic oil and tonkotsu toppings.",
                "restaurant_id": 71,
                "id": 86
            ],
            "image": [
                "link": "https://s3.us-east-2.amazonaws.com/foodie-prod-menu-item-images/admin/c1c8a4e0-98d8-4b4f-8b2b-417499617cf6.png",
                "menu_item_id": 86,
                "restaurant_id": 71
            ],
            "profile": [
                "date": "2019-01-03T00:00:00",
                "status": 1
            ]
        ]
        let json4: JSON = [
            "item": [
                "normalized_name": "Black Tonkotsu Ramen",
                "name": "Black Tonkotsu Ramen",
                "price": 12.95,
                "description": "Hakata style pork bone soup with blackened garlic oil and tonkotsu toppings.",
                "restaurant_id": 71,
                "id": 86
            ],
            "image": [
                "link": "https://s3.us-east-2.amazonaws.com/foodie-prod-menu-item-images/admin/c1c8a4e0-98d8-4b4f-8b2b-417499617cf6.png",
                "menu_item_id": 86,
                "restaurant_id": 71
            ],
            "profile": [
                "date": "2019-01-04T00:00:00",
                "status": 1
            ]
        ]
        
        return [ProfileDish(json: json1), ProfileDish(json: json2), ProfileDish(json: json3), ProfileDish(json: json4)]
    }
}
