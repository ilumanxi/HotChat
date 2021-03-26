//
//  HeadlineAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya

enum HeadlineAPI {
    
    /// resultCode：1120成功1121内容违规1122 能量不足 1123 失败
    case topHeadlines(content: String)
}



extension HeadlineAPI: TargetType {

    
    var path: String {
        switch self {
        case .topHeadlines:
            return "Headlines/topHeadlines"
        }
    }
    
    
    var task: Task {
        let parameters: [String : Any]
        
        switch self {
        case .topHeadlines(let content):
            parameters = [
                "content" : content
            ]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
