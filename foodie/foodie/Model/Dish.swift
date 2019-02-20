//
//  Dish.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Dish {
    var dishId: Int
    var name: String = ""
    var image: String?
    var price: Float = 0
    var description: String = ""
    var restaurantId: Int
    var itemMetadata: Metadata
    var imageMetadata: Metadata

    init(json: JSON) {
        name = json["item"]["normalized_name"].string ?? ""
        image = json["image"]["link"].string
        price = json["item"]["price"].float ?? 0
        description = json["item"]["description"].string ?? ""
        restaurantId = json["item"]["restaurant_id"].int ?? -1
        dishId = json["item"]["id"].int ?? -1
        itemMetadata = Metadata(json: json["image"])
        imageMetadata = Metadata(json: json["item"])
    }
}

enum DishApprovalStatus: Int {
    case none
    case approved
    case pending
    case notapproved
}

class ProfileDish: Dish {
    var date: Date
    var approvalStatus: DishApprovalStatus
    var notApprovedReason: String?

    override init(json: JSON) {
        date = Date(timeIntervalSince1970: json["profile"]["date"].double ?? 0)

        approvalStatus = DishApprovalStatus(rawValue: json["profile"]["status"].int ?? 0) ?? .none
        if approvalStatus == .notapproved {
            notApprovedReason = json["profile"]["notapprovedreason"].string ?? ""
        }

        super.init(json: json)
    }
}
