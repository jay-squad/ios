//
//  Metadata.swift
//  foodie
//
//  Created by Austin Du on 2019-02-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class Metadata {
    
    var createdAt: Date?
    var updatedAt: Date?
    var isApproved: Bool
    
    init(json: JSON) {
        createdAt = FoodieDateFormatter.server.date(from: json["created_at"].string ?? "")
        updatedAt = FoodieDateFormatter.server.date(from: json["updated_at"].string ?? "")
        isApproved = json["is_approved"].bool ?? true
    }
}
