//
//  MesssageAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/13.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum MesssageAPI {
    case knowPeople
}


extension MesssageAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .knowPeople:
            return "News/knowPeople"
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
        case .knowPeople:
            parameters = [:]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
