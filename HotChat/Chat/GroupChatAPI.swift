//
//  GroupChatAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/18.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya


enum GroupChatAPI {
    case groupList
    case groupStatus(groupId: String)
    case getGroupList(groupId: String, type: Int, page: Int)
    case userGroupStatus(groupId: String)
    case getNotice(groupId: String)
}


extension GroupChatAPI: TargetType {
    
    
    var path: String {
     
        switch self {
        case .groupList:
            return "GroupChat/groupList"
        case .groupStatus:
            return "GroupChat/groupStatus"
        case .getGroupList:
            return "GroupChat/getGroupList"
        case .userGroupStatus:
            return "GroupChat/userGroupStatus"
        case .getNotice:
            return "GroupChat/getNotice"
        }
    }
    
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
       
        case .groupList:
            parameters = [ : ]
        case .groupStatus(let groupId):
            parameters = ["groupId" : groupId ]
        case .getGroupList(let groupId, let type, let page):
            parameters = [
                "groupId" : groupId,
                "type" : type,
                "page" : page
            ]
        case .userGroupStatus(let groupId):
            parameters = ["groupId" : groupId]
        case .getNotice(let groupId):
            parameters = ["groupId" : groupId]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
