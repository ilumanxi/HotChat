//
//  UserActivityAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya


enum UserActivityAPI {
    case checkActivityInfo
    case receiveReward
    case receiveKeepReward
}



extension UserActivityAPI: TargetType {

    
    var path: String {
        switch self {
        case .checkActivityInfo:
            return "UserActivity/checkActivityInfo"
        case .receiveReward:
            return "UserActivity/receiveReward"
        case .receiveKeepReward:
            return "UserActivity/receiveKeepReward"
        }
    }
    
    
    var task: Task {
        let parameters: [String : Any]
        
        switch self {
        case .checkActivityInfo, .receiveReward, .receiveKeepReward:
            parameters = [ : ]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
