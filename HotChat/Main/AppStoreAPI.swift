//
//  AppStoreAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/7/7.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya

enum AppStoreAPI {
    case check(userId: String)
}


extension AppStoreAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .check(let userId):
            return "v1/check/ios/\(userId)"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        case .check:
            parameters = [
                "a" : UUID().uuidString,
                "b" : UUID().uuidString
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
