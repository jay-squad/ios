//
//  Profile.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyUserDefaults

extension DefaultsKeys {
    static let existingAmazonCodes = DefaultsKey<[String]>("existing_amazon_codes")
}

class Profile {
    var id: Int = -1
    var name: String = "You"
    var points: Int = -1
    var metadata: Metadata?
    var submissions: [Submission] = []
    var amazonCode: String?
    var shouldShowConfetti = false
    var lastRewardsPoints: Int = -1
    
    init(json: JSON) {
        if let profileJson = json.array?[0] {
            id = profileJson["id"].int ?? -1
            name = profileJson["name"].string ?? ""
            points = profileJson["points"].int ?? 0
            metadata = Metadata(json: profileJson)
            lastRewardsPoints = profileJson["last_reward_points"].int ?? -1
            
            amazonCode = profileJson["amazon_code"].string
            if amazonCode == "" {
                amazonCode = nil
            }

            var existingAmazonCodes = Defaults[.existingAmazonCodes]
            if let amazonCode = amazonCode, !existingAmazonCodes.contains(amazonCode) {
                existingAmazonCodes.append(amazonCode)
                Defaults[.existingAmazonCodes] = existingAmazonCodes
                shouldShowConfetti = true
                Defaults[.answeredSkillTestingQuestion] = false
            }
            
            if let submissions = profileJson["submissions"].array {
                for submission in submissions {
                    self.submissions.append(Submission(json: submission))
                }
            }
        }
    }
}
