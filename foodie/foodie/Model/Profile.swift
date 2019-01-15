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
    var submissions: [Dish] = []
    
    // TODO: remove this once server is good to go
    init(id: Int,
         name: String,
         points: Int,
         submissions: [Dish]) {
        self.id = id
        self.name = name
        self.points = points
        self.submissions = submissions
    }
    
    init(json: JSON) {
        id = json["id"].int ?? -1
        name = json["name"].string ?? ""
        points = json["points"].int ?? -1
        
        for dish in json["submissions"].array ?? [] {
            let dish = Dish(json: dish)
            submissions.append(dish)
        }
    }
}
