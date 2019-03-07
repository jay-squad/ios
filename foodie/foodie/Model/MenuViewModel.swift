//
//  MenuViewModel.swift
//  foodie
//
//  Created by Austin Du on 2018-06-24.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation

enum MenuCellType {
    case column3
    case column1
    case expanded
    case condensed
}

class MenuViewModel {
    var activeMenuType: RestaurantDetailDisplayOption
    var orders: [RestaurantDetailDisplayOption: [[MenuCellType]]] = [:]
    
    init(type: RestaurantDetailDisplayOption) {
        activeMenuType = type
        orders[.grid] = []
        orders[.expanded] = []
        orders[.list] = []
    }
    
    func setDataSource(menu: Menu) {
        var sectionindex: Int = 0
        for menusection in menu.sections {
            if menusection.name == kNoSection && menusection.dishes.count == 0 {
                continue
            }

            orders[.grid]?.append([])
            orders[.expanded]?.append([])
            orders[.list]?.append([])
            
            var count: Int = 0
            for _ in menusection.dishes {
                if count == 0 {
                    orders[.grid]?[sectionindex].append(.column3)
                }
                orders[.expanded]?[sectionindex].append(.expanded)
                orders[.list]?[sectionindex].append(.condensed)
                count += 1
                count %= 3
            }
            sectionindex += 1
        }
    }
    
    func toggleExpand(indexPath: IndexPath, position: Int = 0) {
        switch activeMenuType {
        case .grid:
            orders[.grid]?[indexPath.section][indexPath.row] = .column1
            orders[.grid]?[indexPath.section][indexPath.row] = .expanded
            orders[.grid]?[indexPath.section].insert(.column1, at: indexPath.row+1)
            orders[.grid]?[indexPath.section].insert(.column1, at: indexPath.row-1)
        case .list:
            orders[.list]?[indexPath.section][indexPath.row] = .expanded
        case .expanded:
            break
        }
    }
    
}
