//
//  AuthenticationAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

enum AuthenticationAPI {
    case liveEditAttestation(AnchorAuthentication)
}

extension AuthenticationAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .liveEditAttestation:
            return "LiveAuthentication/liveEditAttestation"
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
        case .liveEditAttestation(let info):
            parameters = [
                "userName" : info.name ?? "",
                "identityNum" : info.card ?? "",
                "identityPicFront" : info.front?.remote?.absoluteString ?? "",
                "identityPicFan" : info.back?.remote?.absoluteString ?? "",
                "handIdentityPic" : info.handHeld?.remote?.absoluteString ?? ""
            ]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
