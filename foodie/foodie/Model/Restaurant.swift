//
//  Restaurant.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class Restaurant {
    var id: Int
    var name: String
    var cuisine: [String]
    var priceRange: [Int]
    var description: String?
    var medals: [RestaurantMedal] = []
    var website: String?
    var phoneNum: String?
    var location: CLLocationCoordinate2D
    var menu: Menu?

    // TODO: remove this once server is good to go
    init(id: Int,
         name: String,
         cuisine: [String],
         priceRange: [Int],
         location: CLLocationCoordinate2D,
         description: String? = nil,
         medals: [RestaurantMedal] = [],
         website: String? = nil,
         phoneNum: String? = nil) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.priceRange = priceRange
        self.location = location
        self.description = description
        self.medals = medals
        self.website = website
        self.phoneNum = phoneNum
    }
    
    init(json: JSON) {
        id = json["id"].int ?? -1
        name = json["normalized_name"].string ?? ""
        location = CLLocationCoordinate2D(latitude: json["latitude"].double ?? 0,
                                          longitude: json["longitude"].double ?? 0)
        website = json["website"].string ?? ""
        phoneNum = json["phone_number"].string ?? ""
        description = json["description"].string ?? ""
        priceRange = [] // TODO
        cuisine = [] // TODO
    }
}
