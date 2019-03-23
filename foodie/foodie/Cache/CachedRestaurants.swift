//
//  CachedRestaurants.swift
//  foodie
//
//  Created by Austin Du on 2019-03-19.
//  Copyright © 2019 JAY. All rights reserved.
//

import Foundation

class CachedRestaurants {
    var timer: Timer?
    
    static let shared: CachedRestaurants = {
        let instance = CachedRestaurants()
        return instance
    }()
    
    private init() {
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(clownyFillCacheIfNeeded), userInfo: nil, repeats: false)
    }
    
    var internalAll: [Restaurant] = []
    var all: [Restaurant] {
        clownyFillCacheIfNeeded()
        return internalAll
    }
    
    @objc private func clownyFillCacheIfNeeded() {
        if internalAll.count == 0 {
            NetworkManager.shared.searchRestaurant(query: "") { (json, _, _) in
                var searchResults: [SearchResult] = []
                if let restaurantJSONs = json?.array {
                    for restaurantJSON in restaurantJSONs {
                        var images: [String?] = []
                        if let minimenu = restaurantJSON["menu"].array {
                            for item in minimenu {
                                if let imageUrl = item[1][0]["item_images"][0]["link"].string {
                                    images.append(imageUrl)
                                }
                            }
                        }
                        searchResults.append(SearchResult(restaurant:
                            Restaurant(json: restaurantJSON["restaurant"]), restaurantImages: images))
                    }
                    self.internalAll = searchResults
                        .filter({ return $0.restaurant != nil })
                        .map({ return $0.restaurant! })
                }
            }
        }
    }
}
