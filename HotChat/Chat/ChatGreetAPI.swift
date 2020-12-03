//
//  ChatGreetAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya


enum ChatGreetAPI {
    /// 0默认所有 1审核通过
    case greetList(type: Int)
    case addGreet(content: String)
    case delGreet(id: String)
    case checkGreet(toUserId: String)
}


extension ChatGreetAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .greetList:
            return "ChatGreet/greetList"
        case .addGreet:
            return "ChatGreet/addGreet"
        case .delGreet:
            return "ChatGreet/delGreet"
        case .checkGreet:
            return "ChatGreet/checkGreet"
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
        case .greetList(let type):
            parameters = ["type": type]
        case .addGreet(let content):
            parameters = ["content": content]
        case .delGreet(let id):
            parameters = ["id": id]
        case .checkGreet(let toUserId):
            parameters = ["toUserId": toUserId]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
