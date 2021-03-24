//
//  BannerAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/18.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya
import HandyJSON

struct Banner: HandyJSON {
    var url: String = ""
    var img: String = ""
    var type: Int = 1
}

enum BannerAPI {
    case bannerList(type: Int)
}

extension BannerAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .bannerList:
            return "Banner/bannerList"
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
        case .bannerList(let type):
            parameters = [
                "type" : type
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
