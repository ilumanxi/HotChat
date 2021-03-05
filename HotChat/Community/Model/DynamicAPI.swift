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
    case comment(content: String, dynamicId: String, parentId: String?, commentId: String?)
    case commentList(dynamicId: String, parentId: String?, page: Int)
    case commentZan(dynamicId: String, commentId: String)
    case delComment(commentId: String)
    case commentReport(content: String, dynamicId: String, commentId: String)
    
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
        case .comment:
            return "Dynamic/comment"
        case .commentList:
            return "Dynamic/commentList"
        case .commentZan:
            return "Dynamic/commentZan"
        case .delComment:
            return "Dynamic/delComment"
        case .commentReport:
            return "Report/commentReport"
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
        case .comment(let content, let dynamicId, let parentId, let commentId):
            parameters = [
                "content" : content,
                "dynamicId" : dynamicId,
                "parentId" : parentId?.description ?? "",
                "commentId" : commentId?.description ?? ""
            ]
        case .commentList(let dynamicId, let parentId, let page):
            parameters = [
                "dynamicId": dynamicId,
                "parentId" : parentId?.description ?? "",
                "page" : page
            ]
        case .commentZan(let dynamicId, let commentId):
            parameters = [
                "dynamicId" : dynamicId,
                "commentId" : commentId
            ]
        case .delComment(let commentId):
            parameters = [
                "commentId" : commentId
            ]
        case .commentReport(let content, let dynamicId, let commentId):
            parameters = [
                "content" : content,
                "dynamicId" : dynamicId,
                "commentId" : commentId
            ]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
