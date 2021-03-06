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
    case countProfit
    case profitImList
    case profitGiftList(page: Int)
    case countMonthProfit
    case profitList(page: Int, tag: Int)
}


extension ConsumerAPI: TargetType {
    
    var path: String {
        switch self {
        case .detailsList:
            return "ConsumerDetails/detailsList"
        case .countProfit:
            return "ConsumerDetails/countProfit"
        case .profitImList:
            return "ConsumerDetails/profitImList"
        case .profitGiftList:
            return "ConsumerDetails/profitGiftList"
        case .countMonthProfit:
            return "ConsumerDetails/countMonthProfit"
        case .profitList:
            return "ConsumerDetails/profitList"
        }
    }
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        case .detailsList(let page, let tag):
            parameters = [
                "page" : page,
                "tag": tag
            ]
        case .countProfit:
            parameters = [:]
        case .profitImList:
            parameters = [:]
        case .profitGiftList(let page):
            parameters = [
                "page" : page
            ]
        case .countMonthProfit:
            parameters = [:]
        case .profitList(let page, let tag):
            parameters = [
                "page" : page,
                "tag": tag
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
