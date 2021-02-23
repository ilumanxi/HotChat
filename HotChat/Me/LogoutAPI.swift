//
//  LogoutAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum LogoutAPI {
    case checkPassword(password: String)
    case checkCodes(verifyCode: String)
    case removeLogout(token: String)
}


extension LogoutAPI: TargetType {
    
    var path: String {
        switch self {
       
        case .checkPassword:
            return "Logout/checkPassword"
        case .checkCodes:
            return "Logout/checkCodes"
        case .removeLogout:
            return "Logout/removeLogout"
        }
    }
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        case .checkPassword(let password):
            parameters = ["password" : password.md5()]
        case .checkCodes(let verifyCode):
            parameters = ["verifyCode" : verifyCode]
        case .removeLogout(let token):
            parameters = ["token" : token]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
