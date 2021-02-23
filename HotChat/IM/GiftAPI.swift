//
//  GiftAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import RxSwift
import MJExtension

enum GiftAPI {
    case giftNumConfig
}

extension GiftAPI: TargetType {

    var path: String {
        switch self {
        case .giftNumConfig:
            return "Gift/giftNumConfig"
        }
    }
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        
        case .giftNumConfig:
            parameters = [:]
        }
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
}



@objc class GiftHelper: NSObject {
    
    static let API  = Request<GiftAPI>()
    
    static let disposeObject = DisposeBag()
    
    static let key = "GiftHelper.cacheGifCountConfig"
    
    @objc class var cacheGifCountConfig: [GiftCountDescription]? {
        
        get {
            let json = UserDefaults.standard.object(forKey: key) as? [[String: Any]]
            return json?.compactMap{ GiftCountDescription.deserialize(from: $0) }
        }
        set {
            guard let data = newValue else {
                UserDefaults.standard.set(nil, forKey: key)
                return
            }
           let json =  data.compactMap { $0.toJSON() }
           UserDefaults.standard.set(json, forKey: key)
        }
    }
    
    @objc class func giftNumConfig(success: @escaping ([GiftCountDescription]) -> Void, failed: @escaping (Error) -> Void) {
        
        API.request(.giftNumConfig, type: Response<[GiftCountDescription]>.self)
            .verifyResponse()
            .subscribe(onSuccess: {  response in
                let data = response.data ?? []
                cacheGifCountConfig = data
                success(data)
            }, onError: { error in
                failed(error)
            })
            .disposed(by: disposeObject)
    }
}
