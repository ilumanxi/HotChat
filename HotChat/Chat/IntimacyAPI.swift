//
//  IntimacyAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

enum IntimacyAPI {
    case intimacyList(userList: [String])
    case intimacyInfo(toUserId: String)
}

extension IntimacyAPI: TargetType {
    
    
    var path: String {
        switch self {
        case .intimacyList:
            return "Intimacy/intimacyList"
        case .intimacyInfo:
            return "Intimacy/intimacyInfo"
        }
    }
    
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        case .intimacyList(let userList):
            parameters = ["userList" : userList]
        case .intimacyInfo(let toUserId):
            parameters = ["toUserId" : toUserId]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}

@objc class IntimacyHelper: NSObject {
    
    let API  = Request<IntimacyAPI>()
    
    @objc func intimacyList(_ userList: [String], success: @escaping ([String : Any]) -> Void, failed: @escaping (NSError) -> Void) {
        
        API.request(.intimacyList(userList: userList), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { response in
                success(response.data ?? [:])
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: rx.disposeBag)
    }
    
}
