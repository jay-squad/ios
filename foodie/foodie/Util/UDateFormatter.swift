//
//  UDateFormatter.swift
//  foodie
//
//  Created by Austin Du on 2019-01-16.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation

class FoodieDateFormatter: DateFormatter {
    static let shared = FoodieDateFormatter(dateFormat: "MMMM dd, YYYY")
    static let server = FoodieDateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX")
    
    private init(dateFormat: String) {
        super.init()
        timeStyle = .none
        self.dateFormat = dateFormat
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DateFormatter {
    
    static func friendlyStringForDate(date: Date) -> String {
        // Fetch the default calendar
        let calendar = Calendar.current        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return FoodieDateFormatter.shared.string(from: date)
        }
    }
}
