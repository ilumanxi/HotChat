//
//  SearchAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/20.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya


enum SearchAPI {
    case searchList(searchContent: String, page: Int)
}


extension SearchAPI: TargetType {
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .searchList:
            return "Search/searchList"
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
        case .searchList(let searchContent,let page):
            parameters = [
                "searchContent" : searchContent,
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
