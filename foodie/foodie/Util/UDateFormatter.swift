//
//  UDateFormatter.swift
//  foodie
//
//  Created by Austin Du on 2019-01-16.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation

class FoodieDateFormatter: DateFormatter {
    static let shared = FoodieDateFormatter()
    
    private override init() {
        super.init()
        timeStyle = .none
        dateFormat = "MMMM dd, YYYY"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DateFormatter {
    
    static func friendlyStringForDate(date: Date) -> String {
        // Fetch the default calendar
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.day]
        
        // Compute days difference between the two
        let delta = (calendar as NSCalendar).components(unitFlags, from: date, to: Date(), options: [])
        
        if let day = delta.day {
            
            switch day {
            case 0:
                return "Today"
                
            case 1:
                return "Yesterday"
                
            default:
                return FoodieDateFormatter.shared.string(from: date)
            }
        }
        return ""
    }
}
