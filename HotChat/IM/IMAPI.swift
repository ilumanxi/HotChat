//
//  IMAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import Kingfisher
import RxSwift
import RxCocoa

extension UIImageView {
    @objc func setKF(_ url: URL?) {
        kf.indicatorType = .activity
        kf.setImage(with: url)
    }
}

enum IMAPI {
    case call(type: Int, toUserId: String)
    case checkUserCall(type: Int, toUserId: String)
    case getCallTime(roomId: Int)
}

extension IMAPI: TargetType {

    var path: String {
        switch self {
        case .call:
            return "Im/call"
        case .checkUserCall:
            return "Im/checkUserCall"
        case .getCallTime:
            return "Im/getCallTime"
        }
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
        case .getCallTime(let roomId):
            parameters = [
                "roomId" : roomId
            ]
        }
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
}


@objc class IMHelper: NSObject {
    

    static let API  = Request<IMAPI>()
    
    static let disposeObject = DisposeBag()
    
    @objc class func  getCallTime(_ roomId: Int, success: @escaping ([String : Any]) -> Void, failed: @escaping (NSError) -> Void) {
        
        API.request(.getCallTime(roomId: roomId), type: Response<[String : Any]>.self).verifyResponse()
            .subscribe(onSuccess: { response in
                success(response.data ?? [:])
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: disposeObject)
    }
}
