//
//  UserAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/25.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import Moya


enum UserAPI {
    
    case userinfo
    case editUser(value: [String : Any])
    case editTips(labelId: Int, content: String)
    
    /// 获取配置：1喜欢女生标签 2小编专访 3运动 4美食 5音乐 6书籍 7旅行 8电影 9行业
    case userConfig(type: Int)
    
    case delQuestion(labelId: Int)
    
    case followList(type: Int)
    
    case userEditAttestation(userName: String, identityNum: String, identityPicFront: String?, identityPicFan: String?)
    case userAttestationInfo
}


extension UserAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    
    var path: String {
        switch self {
        case .editUser:
            return "user/editUser"
        case .userinfo:
            return "user/userinfo"
        case .userConfig:
            return "user/userConfig"
        case .editTips:
            return "user/editTips"
        case .delQuestion:
            return "user/delQuestion"
        case .followList:
            return "user/followList"
        case .userEditAttestation:
            return "user/userEditAttestation"
        case .userAttestationInfo:
            return "user/userAttestationInfo"
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
        case .editUser(value: let value):
            parameters = value
        case .userinfo:
            parameters =  [:]
        case .userConfig(type: let type):
            parameters =  ["type" : type ]
        case .editTips(labelId: let labelId, content: let content):
            parameters = [
                "labelId" : labelId,
                "content" : content
            ]
        case .delQuestion(labelId: let labelId):
            parameters = [
                "labelId" : labelId
            ]
        case .followList(type: let type):
            parameters =  ["type" : type ]
        case .userEditAttestation(userName: let userName, identityNum: let identityNum, identityPicFront: let identityPicFront, identityPicFan: let identityPicFan):
            parameters = [
                "userName" : userName,
                "identityNum" : identityNum,
                "identityPicFront" : identityPicFront ?? "",
                "identityPicFan" : identityPicFan ?? ""
            ]
        case .userAttestationInfo:
            parameters =  [:]
        }
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
