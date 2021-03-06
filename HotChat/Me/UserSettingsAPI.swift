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
    /// 1开启视频聊天，2语音聊天 3免打扰, 4定位开启
    case editSettings(type: Int,value: Int)
    case location(CLLocation)
    case bindPhone(phone: String, verifyCode: String, password: String)
    case appStart
    case appAudit
    case taskConfig(type: Int)
    case chargeConfig
    case downResources
}


extension UserSettingsAPI: TargetType {
    
    var path: String {
        switch self {
        case .infoSettings:
            return "UserSettings/infoSettings"
        case .editSettings:
            return "UserSettings/editSettings"
        case .location:
            return "UserSettings/baiduMap"
        case .bindPhone:
            return "UserSettings/bindPhone"
        case .appStart:
            return "UserSettings/appStart"
        case .appAudit:
            return "UserSettings/appAudit"
        case .taskConfig:
            return "UserSettings/taskConfig"
        case .chargeConfig:
            return "UserSettings/chargeConfig"
        case .downResources:
            return "UserSettings/downResources"
        }
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
        case .bindPhone(let phone, let verifyCode, let password):
            parameters = [
                "phone" : phone,
                "verifyCode" : verifyCode,
                "password" : password
            ]
        case .appStart, .appAudit:
            parameters = [:]
        case .taskConfig(let type):
            parameters = [
                "type" : type
            ]
        case .chargeConfig:
            parameters = [:]
        case .downResources:
            parameters = [:]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
