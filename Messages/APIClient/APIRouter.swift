//
//  APIRouter.swift
//  Base
//
//  Created by Hoàng Anh on 06/08/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    // MARK: Define API
    case getRepositories(key: String)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .getRepositories:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .getRepositories:                 return "/search/repositories"
        }
    }
    
    // MARK: - Headers
    private var headers: [String: String] {
        let headers: [String: String] = [
            "Authorization": "UserManager.shared.tokenType +  + UserManager.shared.accessToken",
            "Accept": "application/json",
            "X-Language": "jp",
            "X-Version": "1"
        ]
        return headers
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .getRepositories:
            return nil
        }
    }
    
    private var urlParameter: [String: Any?]? {
        switch self {
        case .getRepositories(let key):
            return ["q": key]
        }
    }
    
    // MARK: - URL request
    func asURLRequest() throws -> URLRequest {
        var url = URL(string: Config.shared.baseUrl)!
        
        // setting path
        url = url.appendingPathComponent(path)
        
        // appending url parameter
        if let urlParameter = urlParameter {
            url = URL(string: url.absoluteString + urlParameter.asURLParams()) ?? url
        }
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // setting header
        for (key, value) in headers {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        if let parameters = parameters {
            do {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            } catch {
                print("Encoding fail")
            }
        }
        
        return urlRequest
    }
    
}
