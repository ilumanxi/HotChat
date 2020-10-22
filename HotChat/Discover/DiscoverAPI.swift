//
//  DiscoverAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/15.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum DiscoverAPI {
    case labelList
    case discoverList(type: String, labelId: Int, page: Int)
}


extension DiscoverAPI: TargetType {
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .labelList:
            return "Discover/labelList"
        case .discoverList:
            return "Discover/discoverList"
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
        case .labelList:
            parameters = [:]
        case .discoverList(let type, let labelId, let page):
            parameters = [
                "type" : type,
                "labelId" : labelId,
                "page" : page
            ]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}