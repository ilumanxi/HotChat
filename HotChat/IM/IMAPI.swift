//
//  IMAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import Kingfisher

extension UIImageView {
    @objc func setKF(_ url: URL?) {
        kf.indicatorType = .activity
        kf.setImage(with: url)
    }
}

enum IMAPI {
    case call(type: Int, toUserId: String)
    case checkUserCall(type: Int, toUserId: String)
}

extension IMAPI: TargetType {

    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .call:
            return "Im/call"
        case .checkUserCall:
            return "Im/checkUserCall"
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
        
        case .call(let type, let toUserId):
            parameters = [
                "type" : type,
                "toUserId" : toUserId
            ]
        case .checkUserCall(let type, let toUserId):
            parameters = [
                "type" : type,
                "toUserId" : toUserId
            ]
        }
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
