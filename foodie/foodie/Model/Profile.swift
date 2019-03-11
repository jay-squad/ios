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
    var id: Int = -1
    var name: String = "You"
    var points: Int = -1
    var metadata: Metadata?
    
    var submissions: [Submission] = []
    
    init(json: JSON) {
        if let profileJson = json.array?[0] {
            id = profileJson["id"].int ?? -1
            name = profileJson["name"].string ?? ""
            points = profileJson["points"].int ?? 0
            metadata = Metadata(json: profileJson)
            
            if let submissions = profileJson["submissions"].array {
                for submission in submissions {
                    self.submissions.append(Submission(json: submission))
                }
            }
        }
    }
}
