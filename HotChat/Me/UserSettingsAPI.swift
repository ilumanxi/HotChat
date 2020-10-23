//
//  UserSettingsAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum UserSettingsAPI {
    case infoSettings
    case editSettings(type: Int,value: Int)
}


extension UserSettingsAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .infoSettings:
            return "UserSettings/infoSettings"
        case .editSettings:
            return "UserSettings/editSettings"
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
        case .infoSettings:
            parameters = [:]
        case .editSettings(let type, let value):
            parameters = [
                "type" : type,
                "value" : value
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
