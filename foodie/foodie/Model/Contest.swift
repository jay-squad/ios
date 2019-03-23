//
//  Contest.swift
//  foodie
//
//  Created by Austin Du on 2019-03-22.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class Contest {
    static var shared: Contest?
    
    var numContestants: Int = 0
    var endTime: Date = Date(timeIntervalSince1970: 0)
    var isActive: Bool
    var text: String = ""
    
    init(json: JSON) {
        isActive = json["is_active"].bool ?? false
        
        if isActive {
            numContestants = json["num_contestants"].int ?? 0
            endTime = Date(timeIntervalSince1970: json["end_time"].double ?? 0)
            text = json["text"].string ?? ""
        }
    }
    
    static func fetchContest(completion: (() -> Void)?) {
        NetworkManager.shared.getContestRules { (json, _, _) in
            if let json = json {
                Contest.shared = Contest(json: json)
                completion?()
            }
        }
    }
}
