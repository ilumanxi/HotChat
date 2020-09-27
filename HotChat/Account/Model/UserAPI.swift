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
        }
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
