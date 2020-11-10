//
//  Consumer.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum ConsumerAPI {
    case detailsList(page: Int, tag: Int)
}


extension ConsumerAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .detailsList:
            return "ConsumerDetails/detailsList"
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
        case .detailsList(let page, let tag):
            parameters = [
                "page" : page,
                "tag": tag
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
