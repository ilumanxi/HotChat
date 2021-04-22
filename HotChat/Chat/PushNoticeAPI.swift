//
//  PushNoticeAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya

enum PushNoticeAPI {
    ///10003推荐 10004 上线
    case pushNoticeList(type: Int, page: Int)
}

extension PushNoticeAPI: TargetType {
    
    
    var path: String {
     
        switch self {
        case .pushNoticeList:
            return "PushNotice/pushNoticeList"
        }
    }
    
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
       
        case .pushNoticeList(let type, let page):
            parameters = [
                "type" : type,
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
