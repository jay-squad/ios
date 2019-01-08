//
//  RequestBodyFactory.swift
//  foodie
//
//  Created by Austin Du on 2018-07-04.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import SwiftyJSON

class RequestBodyFactory {
    static let shared: RequestBodyFactory = {
        let instance = RequestBodyFactory()
        return instance
    }()
    
    func updateMenuItem( imageUrl: String? ) -> [String: Any] {
        var jsonDict: [String: AnyObject] = [:]
        
        if let imageUrl = imageUrl {
            jsonDict["item_image"] = imageUrl as AnyObject?
        }
        
        return jsonDict
    }
    
}
