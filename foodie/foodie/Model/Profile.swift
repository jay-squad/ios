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
        
        if let submissions = json.array?[0]["submissions"].array {
            for submission in submissions {
                self.submissions.append(Submission(json: submission))
            }
        }
    }
}
