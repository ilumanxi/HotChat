//
//  UpgradeAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/18.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum UpgradeAPI {
    case updateChannel
}

extension UpgradeAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .updateChannel:
            return "VersionUpgrade/updateChannel"
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
        case .updateChannel:
            parameters = [
                "deviceType" : 1,
                "channelType" : 1,
                "VersionCode" : Bundle.main.appVersion
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
