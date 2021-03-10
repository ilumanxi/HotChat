//
//  TopAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/10.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya


enum TopAPI {
    
    /// 类型：1魅力2富豪  栏目标签：1日榜  2周榜  3月榜   4总榜
    case topList(type: Int, tag: Int)
}


extension TopAPI: TargetType {
    
    var path: String {
        switch self {
        case .topList:
            return "Statistics/topList"
        }
    }
    
    var task: Task {
        let parameters: [String : Any]
        
        switch self {
        case .topList(let type, let tag):
            parameters = [
                "type" : type,
                "tag" : tag
            ]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
}
