//
//  ReportAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/14.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya


enum ReportAPI {
    case reportConfig(Int) //举报类型 1动态举报 2用户举报
    case userReport([String : Any])
    case dynamicReport(dynamicId: String, content: String)
}

extension ReportAPI: TargetType {
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .reportConfig:
            return "Report/reportConfig"
        case .userReport:
            return "Report/userReport"
        case .dynamicReport:
            return "Report/dynamicReport"
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
        case .reportConfig(let type):
            parameters = ["type" : type]
        case .userReport(let value):
            parameters = value
        case .dynamicReport(let dynamicId, let content):
            parameters = [
                "dynamicId" : dynamicId,
                "content" : content
            ]
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
