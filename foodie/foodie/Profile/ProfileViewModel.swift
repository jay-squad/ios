//
//  ProfileViewModel.swift
//  foodie
//
//  Created by Austin Du on 2019-01-15.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProfileSubmissionsViewModel {
    var sectionedSubmissions: [[Submission]] = [[]]
    var isEmpty = false
    
    init(profile: Profile?) {
        guard let profile = profile else { return }
        var submissions = profile.submissions
        
        if submissions.count == 0 {
            isEmpty = true
        }
    
        submissions.sort {
            let date0 = dateOf($0)
            let date1 = dateOf($1)
            return date0 > date1
        }

        for submission in submissions {
            if sectionedSubmissions.last!.isEmpty || Calendar.current.isDate(dateOf(submission), inSameDayAs: dateOf(sectionedSubmissions.last![0])) {
                sectionedSubmissions[sectionedSubmissions.count-1].append(submission)
            } else {
                sectionedSubmissions.append([submission])
            }
        }
    }
    
    func dateOf(_ submission: Submission) -> Date {
        return submission.metadata?.updatedAt ?? Date(timeIntervalSince1970: 0)
    }
}
