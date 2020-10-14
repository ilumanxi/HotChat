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
        }
        
        let encoding: ParameterEncoding = (method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
