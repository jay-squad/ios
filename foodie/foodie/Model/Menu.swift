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
        for section in json["section"].array ?? [] {
            sections.append(MenuSection(json: section))
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

    init(json: JSON) {
        name = json["name"].string ?? ""
        rank = json["rank"].int ?? -1
        if let items = json["items"].array {
            for item in items {
                dishes.append(Dish(json: item))
            }
        }
    }
}
