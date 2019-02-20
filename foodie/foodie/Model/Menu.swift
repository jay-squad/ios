//
//  Menu.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class Menu {
    var sections: [MenuSection] = []
    
    init(json: JSON) {
        var i = 0
        
        for section in json.array ?? [] {
            let newSection = MenuSection(json: section, rank: i)
//            if newSection.dishes.count > 0 {
                sections.append(newSection)
                i += 1
//            }
        }
        sections.sort {$0.rank < $1.rank}
    }
    
    func getDish(section: Int, row: Int) -> Dish? {
        guard section < sections.count && row < sections[section].dishes.count else { return nil }
        return sections[section].dishes[row]
    }
    
}

class MenuSection {
    
    var name: String?
    var rank: Int = -1
    var dishes: [Dish] = []
    var metadata: Metadata

    init(json: JSON, rank: Int) {
        self.rank = rank
        if let arr = json.array {
            name = arr[0].string
            if let items = arr[1].array {
                for item in items {
                    dishes.append(Dish(json: item))
                }
            }
        }
        metadata = Metadata(json: json)
    }
}
