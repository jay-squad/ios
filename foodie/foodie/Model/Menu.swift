//
//  Menu.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

let kNoSection = "(no section)"

class Menu {
    var sections: [MenuSection] = []
    var sectionsDiff: [Int] = []
    var flatDishList: [String] = []
    var searchActive: Bool = false
    
    init(json: JSON) {
        var i = 0
        
        var sectionDeduplicator: [String: MenuSection] = [:]
        
        for section in json.array ?? [] {
            let newSection = MenuSection(json: section, rank: i, menu: self)
            if sectionDeduplicator[newSection.name] == nil {
                sections.append(newSection)
                sectionDeduplicator[newSection.name] = newSection
                i += 1
            } else {
                sectionDeduplicator[newSection.name]?.originalDishes.append(contentsOf: newSection.dishes)
            }
            flatDishList.append(contentsOf: newSection.dishes.map({ $0.name }))
        }
        sections.sort {$0.rank < $1.rank}
    }
    
    func getDish(section: Int, row: Int) -> Dish? {
        guard section < sections.count && row < sections[section].dishes.count else { return nil }
        return sections[section].dishes[row]
    }
    
    func getDish(id: Int) -> Dish? {
        for section in sections {
            for dish in section.dishes where dish.dishId == id {
                return dish
            }
        }
        return nil
    }
    
    func filter(query: String) {
        for section in sections {
            section.filter(query: query)
        }
    }
    
}

class MenuSection {
    
    var name: String = kNoSection
    var rank: Int = -1
    var dishes: [Dish] {
        get {
            if menu?.searchActive ?? false {
                return filteredDishes
            } else {
                return originalDishes
            }
        }
    }
    var originalDishes: [Dish] = []
    var filteredDishes: [Dish] = []
    var metadata: Metadata
    
    var restaurantId: Int = -1

    // for searching only
    private var menu: Menu?

    init(json: JSON, rank: Int, menu: Menu) {
        self.rank = rank
        self.menu = menu
        if let arr = json.array {
            name = arr[0].string ?? kNoSection
            if name == "" {
                name = kNoSection
            }
            if let items = arr[1].array {
                for item in items {
                    originalDishes.append(Dish(json: item))
                }
            }
        }
        metadata = Metadata(json: json)
    }
    
    init(json: JSON) {
        name = json["normalized_name"].string ?? kNoSection
        restaurantId = json["restaurant_id"].int ?? -1
        metadata = Metadata(json: json)
    }
    
    func filter(query: String) {
        filteredDishes = originalDishes.filter({ (dish) -> Bool in
            let range = dish.name.range(of: query, options: .caseInsensitive)
            return range != nil
        })
    }
}
