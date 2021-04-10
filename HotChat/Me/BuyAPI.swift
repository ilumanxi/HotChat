//
//  BuyAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/10.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya

enum BuyAPI {
    case checkBuyUserContact(toUserId: String)
    /// 类型 1qq   2微信  3电话
    case buyContact(type: Int, toUserId: String)
}


extension BuyAPI: TargetType {
    
    var path: String {
        switch self {
        case .checkBuyUserContact:
            return "Buy/checkBuyUserContact"
        case .buyContact:
            return "Buy/buyContact"
        }
    }
    
    var task: Task {
        let parameters: [String : Any]
        
        switch self {
        case .checkBuyUserContact(let toUserId):
            parameters = ["toUserId" : toUserId]
        case .buyContact(let type, let toUserId):
            parameters = [
                "type" : type,
                "toUserId" : toUserId
            ]
        }
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
}
