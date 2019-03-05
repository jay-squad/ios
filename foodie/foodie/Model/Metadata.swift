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
    
    enum ApprovalStatus: String {
        case pending = "pending"
        case rejected = "rejected"
        case approved = "approved"
        case error = ""
    }
    
    var createdAt: Date?
    var updatedAt: Date?
    var approvalStatus: ApprovalStatus
    
    init(json: JSON) {
        createdAt = FoodieDateFormatter.server.date(from: json["created_at"].string ?? "")
        updatedAt = FoodieDateFormatter.server.date(from: json["updated_at"].string ?? "")
        approvalStatus = ApprovalStatus(rawValue: json["approval_status"].string ?? "") ?? .error
    }
}
