//
//  CheckInAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/7.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum CheckInAPI {
    case signList
    case userSignIn
    case checkUserSignInfo
}


extension CheckInAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .signList:
            return "UserSignin/signList"
        case .userSignIn:
            return "UserSignin/userSignIn"
        case .checkUserSignInfo:
            return "UserSignin/checkUserSignInfo"
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
        case .signList:
            parameters = [:]
        case .userSignIn:
            parameters = [:]
        case .checkUserSignInfo:
            parameters = [:]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
