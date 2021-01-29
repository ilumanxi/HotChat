//
//  FateMatchAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/28.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya

enum FateMatchAPI {
    case matchList
    /// 1.语音 2.视频
    case matchGirl(CallType)
}

extension FateMatchAPI: TargetType {
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .matchList:
            return "FateMatch/matchList"
        case .matchGirl:
            return "FateMatch/matchGirl"
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
        case .matchList:
            parameters = [:]
        case .matchGirl(let type):
            parameters = ["type" : type == .audio ? 1 : 2]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
