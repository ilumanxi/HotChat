//
//  PayAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/30.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum PayAPI {
    case ceateOrder([String : Any])
    case notify([String : Any])
}

extension PayAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .ceateOrder:
            return "pay/appleApp"
        case .notify:
            return "AppleNotify/notify"
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
        case .ceateOrder(let params):
            parameters = params
        case .notify(let params):
            parameters = params
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
