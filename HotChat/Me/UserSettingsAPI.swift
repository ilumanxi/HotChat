//
//  UserSettingsAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import CoreLocation

enum UserSettingsAPI {
    case infoSettings
    case editSettings(type: Int,value: Int)
    case location(CLLocation)
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
        case .location:
            return "UserSettings/baiduMap"
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
        case .location(let location):
            parameters = [
                "lat" : location.coordinate.latitude.description,
                "lng" : location.coordinate.longitude.description
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
