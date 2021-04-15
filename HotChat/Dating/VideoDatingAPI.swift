//
//  VideoDatingAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/15.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya

enum VideoDatingAPI {
    case videoList(Int)
}


extension VideoDatingAPI: TargetType {

    
    var path: String {
        switch self {
        case .videoList:
            return "VideoDating/videoList"
        }
    }
    
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        case .videoList(let page):
            parameters = [
                "page" : page
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
