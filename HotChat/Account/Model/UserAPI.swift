//
//  UserAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/25.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import Moya


enum UserAPI {
    
    case userinfo(userId: String?)
    case editUser(value: [String : Any])
    case editTips(labelId: Int, content: String)
    
    /// 获取配置：1喜欢女生标签 2小编专访 3运动 4美食 5音乐 6书籍 7旅行 8电影 9行业
    case userConfig(type: Int)
    
    case delQuestion(labelId: Int)
    
    case followList(type: Int)
    
    case userEditAttestation(userName: String, identityNum: String, identityPicFront: String?, identityPicFan: String?)
    case userAttestationInfo
    case delPhoto(picId: Int)
    
    /// 平台类型 1支付宝微信 2苹果
    case amountList(type: Int)
    
    case remark(friendNick: String, userId: String)
    case batchFollow(followList: [Any])
    case infoInvite
    case editInvite(phone: String)
    case blackList
    case editDefriend(userId: String)
    case userWallet
    case visitorList(Int)
    case checkFollow(userId: String)
    case checkUserHeadPic
}


extension UserAPI: TargetType {
    
    var path: String {
        switch self {
        case .editUser:
            return "user/editUser"
        case .userinfo:
            return "user/userinfo"
        case .userConfig:
            return "user/userConfig"
        case .editTips:
            return "user/editTips"
        case .delQuestion:
            return "user/delQuestion"
        case .followList:
            return "user/followList"
        case .userEditAttestation:
            return "user/userEditAttestation"
        case .userAttestationInfo:
            return "user/userAttestationInfo"
        case .amountList:
            return "user/amountList"
        case .delPhoto:
            return "user/delPhoto"
        case .remark:
            return "User/editFriend"
        case .batchFollow:
            return "Follow/batchFollow"
        case .infoInvite:
            return "user/infoInvite"
        case .editInvite:
            return "user/editInvite"
        case .blackList:
            return "User/blackList"
        case .editDefriend:
            return "User/editDefriend"
        case .userWallet:
            return "user/userWallet"
        case .visitorList:
            return "user/visitorList"
        case .checkFollow:
            return "user/checkFollow"
        case .checkUserHeadPic:
            return "user/checkUserHeadPic"
        }
    }
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        case .editUser(let value):
            parameters = value
        case .userinfo(let userId):
            parameters =  (userId != nil) ? [ "userId": userId!] : [:]
        case .userConfig(let type):
            parameters =  ["type" : type]
        case .editTips(let labelId,let content):
            parameters = [
                "labelId" : labelId,
                "content" : content
            ]
        case .delQuestion(let labelId):
            parameters = [
                "labelId" : labelId
            ]
        case .followList(let type):
            parameters =  ["type" : type ]
        case .userEditAttestation(userName: let userName, identityNum: let identityNum, identityPicFront: let identityPicFront, identityPicFan: let identityPicFan):
            parameters = [
                "userName" : userName,
                "identityNum" : identityNum,
                "identityPicFront" : identityPicFront ?? "",
                "identityPicFan" : identityPicFan ?? ""
            ]
        case .userAttestationInfo:
            parameters =  [:]
        case .amountList(let type):
            parameters =  ["type" : type]
        case .delPhoto(let picId):
            parameters =  ["picId" : picId]
        case .remark(let friendNick,let userId):
            parameters =  [
                "friendNick" : friendNick,
                "userId" : userId
            ]
        case .batchFollow(let followList):
            parameters =  ["followList" : followList]
        case .infoInvite:
            parameters = [:]
        case .editInvite(let phone):
            parameters =  ["phone" : phone]
        case .blackList:
            parameters =  [:]
        case .editDefriend(let userId):
            parameters =  ["userId" : userId]
        case .userWallet:
            parameters =  [:]
        case .visitorList(let page):
            parameters =  ["page" : page]
        case .checkFollow(let userId):
            parameters =  ["userId" : userId]
        case .checkUserHeadPic:
            parameters =  [:]
        }
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
}
