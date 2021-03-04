//
//  DynamicAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import Moya

enum DynamicAPI{
    case releaseDynamic([String : Any])
    case recommendList(Int)
    case zan(String)
    case dynamicList([String : Any])
    case follow(String)
    case delDynamic(String)
    case dynamicCommunity(Int)
    
    
}


extension DynamicAPI: TargetType {
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .releaseDynamic:
            return "Dynamic/releaseDynamic"
        case .recommendList:
            return "Dynamic/recommendList"
        case .zan:
            return "Dynamic/zan"
        case .dynamicList:
            return "Dynamic/dynamicList"
        case .follow:
            return "Dynamic/follow"
        case .delDynamic:
            return "Dynamic/delDynamic"
        case .dynamicCommunity:
            return "Dynamic/community"
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
        case .releaseDynamic(let value):
            parameters = value
        case .recommendList(let page):
            parameters = ["page" : page]
        case .dynamicCommunity(let page):
            parameters = ["page" : page]
        case .zan(let dynamicId):
            parameters = [ "dynamicId" : dynamicId]
        case .dynamicList(let value):
            parameters = value
        case .follow(let followUserId):
            parameters = [ "followUserId" : followUserId]
        case .delDynamic(let dynamicId):
            parameters = [ "dynamicId" : dynamicId]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
