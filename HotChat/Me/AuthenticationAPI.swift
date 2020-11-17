//
//  AuthenticationAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import RxSwift

enum AuthenticationAPI {
    case liveEditAttestation(AnchorAuthentication)
    case faceAttestation(imgFace: String)
    case editFacePic(imgFace: String)
    case checkUserAttestation
}

extension AuthenticationAPI: TargetType {
    
    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .liveEditAttestation:
            return "LiveAuthentication/liveEditAttestation"
        case .faceAttestation:
            return "LiveAuthentication/faceAttestation"
        case .editFacePic:
            return "LiveAuthentication/editFacePic"
        case .checkUserAttestation:
            return "LiveAuthentication/checkUserAttestation"
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
        case .faceAttestation(let imgFace):
            parameters = [
                "imgFace" : imgFace
            ]
        case .editFacePic(let imgFace):
            parameters = [
                "imgFace" : imgFace
            ]
        case .checkUserAttestation:
            parameters = [:]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}


class AuthenticationHelper: NSObject {
    
    
    static let disposeObject = DisposeBag()
    
    static let authentication = Request<AuthenticationAPI>()
    
   @objc class func faceAttestation(imgURL: String, success: @escaping (NSDictionary) -> Void, failed: @escaping (NSError) -> Void) {
        
        authentication.request(.faceAttestation(imgFace: imgURL), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { response in
                success(response.toJSON()! as NSDictionary)
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: disposeObject)
    }
}
