//
//  NetworkManager.swift
//  foodie
//
//  Created by Austin Du on 2018-07-04.
//  Copyright © 2018 JAY. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AWSCore
import AWSS3
import AWSMobileClient
import AWSAuthCore
import FBSDKCoreKit
import MapKit

class NetworkManager {
    
    // This can only be public/, protected/ or /private
    let ks3Prefix = "protected/"
    let kS3baseUrl = "https://s3.us-east-2.amazonaws.com/"
    let kS3bucketName = "foodie-prod-dish-images"
    
    let authCookieName = "fb_access_token"
    #if DEBUG
    let authCookieDomain = "foodie-server-dev.herokuapp.com"
    #else
    let authCookieDomain = "foodie-server-prod.herokuapp.com"
    #endif
    let authCookieSecure = "TRUE"
    let authCookiePath = "/"
    
    static let shared: NetworkManager = {
        let instance = NetworkManager()
        return instance
    }()
    
    enum Router: URLRequestConvertible {
        
        case updateMenuItem(restaurantId: Int, menuItemId: Int, imageUrl: String)
        case getRestaurant(restaurantId: Int)
        case getRestaurantMenu(restaurantId: Int)
        case searchRestaurant(query: String)
        case searchDish(query: String)
        case insertMenuItem(restaurantId: Int, params: [String: AnyObject])
        case getProfile(userId: Int)
        case getProfileSelf()
        case submitAmend(params: [String: AnyObject])
        case submitRestaurant(params: [String: AnyObject])
        case getContestRules()
        case resubmitRestaurant(restaurantId: Int, params: [String: AnyObject])
        
        #if DEBUG
        static let baseURLString = "https://foodie-server-dev.herokuapp.com/"
        #else
        static let baseURLString = "https://foodie-server-prod.herokuapp.com/"
        #endif
        
        var method: HTTPMethod {
            switch self {
            case .updateMenuItem:
                return .put
            case .getRestaurant:
                return .get
            case .getRestaurantMenu:
                return .get
            case .searchRestaurant:
                return .get
            case .searchDish:
                return .get
            case .insertMenuItem:
                return .post
            case .getProfile:
                return .get
            case .getProfileSelf:
                return .get
            case .submitAmend:
                return .post
            case .submitRestaurant:
                return .post
            case .getContestRules:
                return .get
            case .resubmitRestaurant:
                return .put
            }
        }
        
        var path: String {
            switch self {
            case .updateMenuItem(let restaurantId, let menuItemId, _):
                return "restaurant/\(restaurantId)/item/\(menuItemId)"
            case .getRestaurant(let restaurantId):
                return "restaurant/\(restaurantId)"
            case .getRestaurantMenu(let restaurantId):
                return "restaurant/\(restaurantId)/menu"
            case .searchRestaurant(let query):
                return "search/restaurant/\(query)"
            case .searchDish(let query):
                return "search/item/\(query)"
            case .insertMenuItem(let restaurantId, _):
                return "restaurant/\(restaurantId)/item"
            case .getProfile(let userId):
                return "fbuser/\(userId)"
            case .getProfileSelf():
                return "fbuser"
            case .submitAmend(_):
                return "suggest_amendment"
            case .submitRestaurant(_):
                return "restaurant"
            case .getContestRules:
                return "blob/contest_rules"
            case .resubmitRestaurant(let restaurantId, _):
                return "restaurant/\(restaurantId)"
            }
        }
        
        var body: [String: Any] {
            switch self {
            case .updateMenuItem(_, _, let imageUrl):
                return RequestBodyFactory.shared.updateMenuItem(imageUrl: imageUrl)
            case .insertMenuItem(_, let params):
                return params
            case .submitAmend(let params):
                return params
            case .submitRestaurant(let params):
                return params
            case .resubmitRestaurant(_, let params):
                return params
            default:
                return [:]
            }
        }
        
        func asURLRequest() throws -> URLRequest {
            if let authToken = FBSDKAccessToken.current(), authToken.isExpired {
                FBSDKAccessToken.refreshCurrentAccessToken { (_, _, error) in
                    if error != nil {
                        NetworkManager.shared.setAuthedState()
                    }
                }
            }
            
            let url = try Router.baseURLString.asURL()
            
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            urlRequest.timeoutInterval = 60.0
            
            urlRequest = try URLEncoding.default.encode(urlRequest, with: body)
            
            return urlRequest
        }
    }
    
    func getStatusCode( response: DataResponse<Any> ) -> Int {
        if let innerResponse = response.response {
            return innerResponse.statusCode
        } else {
            return -1
        }
    }
    
#if DEBUG
    func grantAdminCookie() {
        setUnAuthedState()
        if let authCookie = HTTPCookie(properties: [.name: "admin_secret_key",
                                                    .value: "udVHE9VWlU[tk]hL$fE9a7CXGg16cy$HiyXswvzaCCzokdb@GL1>Y%pg63qaH(<%" as Any,
                                                    .path: authCookiePath,
                                                    .domain: authCookieDomain,
                                                    .secure: authCookieSecure,
                                                    .expires: FBSDKAccessToken.current().expirationDate]) {
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(authCookie)
        }
    }
#endif
    
    // MARK: Public Functions
    
    func refreshAuthToken(completion: ((Error?) -> Void)? = nil ) {
        FBSDKAccessToken.refreshCurrentAccessToken { (_, _, error) in
            completion?(error)
        }
    }
    
    func setAuthedState() {
        setUnAuthedState()
        if let httpStorage = Alamofire.SessionManager.default.session.configuration.httpCookieStorage,
            let url = URL(string: NetworkManager.Router.baseURLString),
            let cookies = httpStorage.cookies {
            print(cookies)
        }
        if let authCookie = HTTPCookie(properties: [.name: authCookieName,
                                                    .value: FBSDKAccessToken.current()?.tokenString as Any,
                                                    .path: authCookiePath,
                                                    .domain: authCookieDomain,
                                                    .secure: authCookieSecure,
                                                    .expires: FBSDKAccessToken.current().expirationDate]) {
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(authCookie)
        }
        
        if let token = FBSDKAccessToken.current()?.tokenString {
            AWSMobileClient.sharedInstance().federatedSignIn(providerName: IdentityProvider.facebook.rawValue, token: token) { (userState, error)  in
                if let error = error {
                    print("Federated Sign In failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func setUnAuthedState() {
        if let httpStorage = Alamofire.SessionManager.default.session.configuration.httpCookieStorage,
            let url = URL(string: NetworkManager.Router.baseURLString),
            let cookies = httpStorage.cookies {
            for cookie in cookies {
                httpStorage.deleteCookie(cookie)
            }
        }
        AWSMobileClient.sharedInstance().signOut()
    }
    
    func submitAmend(reason: String?,
                     identifier: String?,
                     specifics: String?,
                     isReport: Bool,
                     completion: @escaping (JSON?, Error?, Int) -> Void ) {
        
        var json: JSON = JSON([:])
        
        if let reason = reason {
            json["reason"].string = reason
        }
        if let identifier = identifier {
            json["identifier"].string = identifier
        }
        if let specifics = specifics {
            json["specifics"].string = specifics
        }
        json["amendment_type"].string = isReport ? "report" : "amendment"
        
        Alamofire.request(Router.submitAmend(params: json.dictionaryObject as! [String: AnyObject]))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func insertMenuItem(restaurantId: Int,
                        itemName: String?,
                        itemImage: UIImage?,
                        description: String?,
                        sectionName: String?,
                        price: Float?,
                        completion: @escaping (JSON?, Error?, Int) -> Void ) {
        guard restaurantId >= 0, itemName != nil, itemImage != nil else { return }
        
        uploadImage(image: itemImage, restaurantId: restaurantId) { (url, error) in
            if let urlString = url?.absoluteString, error == nil {
                self.insertMenuItem(restaurantId: restaurantId,
                                   itemName: itemName,
                                   itemImageUrl: urlString,
                                   description: description,
                                   sectionName: sectionName,
                                   price: price,
                                   completion: completion)
            }
        }
    }
    
    func insertMenuItem(restaurantId: Int,
                        itemName: String?,
                        itemImageUrl: String?,
                        description: String?,
                        sectionName: String?,
                        price: Float?,
                        completion: @escaping (JSON?, Error?, Int) -> Void ) {
        guard restaurantId >= 0, itemName != nil, itemImageUrl != nil else { return }

        var json: JSON = JSON([:])
        
        json["item_name"].string = itemName!
        json["item_image"].string = itemImageUrl
        
        if let description = description {
            json["description"].string = description
        }
        if let sectionName = sectionName {
            json["section_name"].string = sectionName
        }
        if let price = price {
            json["price"].float = price
        }
        
        Alamofire.request(Router.insertMenuItem(restaurantId: restaurantId,
                                                params: json.dictionaryObject! as [String: AnyObject]))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func updateMenuItem( restaurantId: Int,
                         menuItemId: Int,
                         image: UIImage?,
                         completion: @escaping (JSON?, Error?, Int) -> Void ) {
        guard image != nil else { return }
        
        // upload to S3
        let imageUrl = "testurl"
        
        Alamofire.request(Router.updateMenuItem(restaurantId: restaurantId,
                                                menuItemId: menuItemId,
                                                imageUrl: imageUrl))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func getRestaurant( restaurantId: Int,
                        completion: @escaping (JSON?, Error?, Int) -> Void ) {
        Alamofire.request(Router.getRestaurant(restaurantId: restaurantId))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func getRestaurantMenu( restaurantId: Int,
                            completion: @escaping (JSON?, Error?, Int) -> Void ) {
        Alamofire.request(Router.getRestaurantMenu(restaurantId: restaurantId))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    // TODO: add menu to CachedRestaurants
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func searchRestaurant( query: String?,
                           completion: @escaping (JSON?, Error?, Int) -> Void ) {
        guard query != nil else { return }
        Alamofire.request(Router.searchRestaurant(query: query!))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func searchDish( query: String?,
                     completion: @escaping (JSON?, Error?, Int) -> Void ) {
        guard query != nil else { return }
        Alamofire.request(Router.searchDish(query: query!))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func getProfile( userId: Int,
                     completion: @escaping (JSON?, Error?, Int) -> Void ) {
        Alamofire.request(Router.getProfile(userId: userId))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func getProfileSelf(completion: @escaping (JSON?, Error?, Int) -> Void ) {
        Alamofire.request(Router.getProfileSelf())
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
        
    func uploadImage(image: UIImage?, restaurantId: Int,
                     completion: @escaping (URL?, Error?) -> Void) {
        
        guard image != nil else { return }
        guard let identityId = AWSMobileClient.sharedInstance().identityId else { return }
        let image = image?.resizeImage(targetSize: CGSize(width: 1080, height: 1080))
        let data: Data = image!.jpegData(compressionQuality: 0 )!
        let key = "\(ks3Prefix)\(identityId)/\(restaurantId)/\(UUID().uuidString).jpg"
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(data,
                                   bucket: kS3bucketName,
                                   key: key,
                                   contentType: "image/jpeg",
                                   expression: expression) { (_, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        completion(nil, error)
                                    } else {
                                        let newImageUrl =  URL(string: "\(self.kS3baseUrl)\(self.kS3bucketName)/\(key)")
                                        print("Successfully uploaded image to: \(newImageUrl?.absoluteString)")
                                        completion(newImageUrl, nil)
                                    }
        }
    }
    
    func submitRestaurant(name: String,
                          location: CLLocationCoordinate2D,
                          description: String?,
                          cuisineType: String?,
                          phoneNumber: String?,
                          website: String?,
                          completion: @escaping (JSON?, Error?, Int) -> Void ) {
        var json: JSON = JSON([:])
        
        json["name"].string = name
        json["latitude"].string = "\(location.latitude)"
        json["longitude"].string = "\(location.longitude)"
        
        if let description = description {
            json["description"].string = description
        }
        if let cuisineType = cuisineType {
            json["cuisine_type"].string = cuisineType
        }
        if let phoneNumber = phoneNumber {
            json["phone_number"].string = phoneNumber
        }
        if let website = website {
            json["website"].string = website
        }
        
        Alamofire.request(Router.submitRestaurant(params: json.dictionaryObject! as [String: AnyObject]))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func resubmitRestaurant(restaurantId: Int,
                            name: String,
                            location: CLLocationCoordinate2D,
                            description: String?,
                            cuisineType: String?,
                            phoneNumber: String?,
                            website: String?,
                            completion: @escaping (JSON?, Error?, Int) -> Void ) {
        var json: JSON = JSON([:])
        
        json["name"].string = name
        json["latitude"].string = "\(location.latitude)"
        json["longitude"].string = "\(location.longitude)"
        
        if let description = description {
            json["description"].string = description
        }
        if let cuisineType = cuisineType {
            json["cuisine_type"].string = cuisineType
        }
        if let phoneNumber = phoneNumber {
            json["phone_number"].string = phoneNumber
        }
        if let website = website {
            json["website"].string = website
        }
        
        Alamofire.request(Router.resubmitRestaurant(restaurantId: restaurantId, params: json.dictionaryObject! as [String: AnyObject]))
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
    
    func getContestRules(completion: @escaping (JSON?, Error?, Int) -> Void) {
        Alamofire.request(Router.getContestRules())
            .responseJSON { response in
                let code = self.getStatusCode( response: response )
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil, code)
                case .failure(let error):
                    completion(nil, error, code)
                }
        }
    }
}
