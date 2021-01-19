//
//  API.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa
import HandyJSON


extension ObservableType where Element == Moya.Response {
    public func map<T: HandyJSON>(_ type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.map(T.self, atKeyPath: keyPath))
        }
    }
}

public extension PrimitiveSequence where Trait == SingleTrait, Element == Moya.Response {

    /// Maps received data at key path into a Decodable object. If the conversion fails, the signal errors.
    func map<D: HandyJSON>(_ type: D.Type, atKeyPath keyPath: String? = nil) -> Single<D> {
        return flatMap { .just( try $0.map(D.self, atKeyPath: keyPath)) }
    } }





extension Moya.Response {
    
    func map<D: HandyJSON>(_ type: D.Type, atKeyPath keyPath: String? = nil) throws -> D {
        do {
            
            if statusCode >= 500 {
              
                throw HotChatError.generalError(reason: .conversionError(string: HTTPURLResponse.localizedString(forStatusCode: statusCode), encoding: .utf8))
            }
            
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
            
            guard let obj = D.deserialize(from: json, designatedPath: keyPath)  else {
                throw MoyaError.jsonMapping(self)
            }
            
            return  obj
            
        } catch let  error {
            throw error
        }
    }
}



class Request<Target: TargetType>: MoyaProvider<Target> {

    convenience init() {
        #if DEBUG
        let plugins: [PluginType] = [
            SignaturePlugin(salt: Constant.Server.salt),
            AccountPlugin(),
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        #else
        let plugins: [PluginType] = [
            SignaturePlugin(salt: Constant.Server.salt),
            AccountPlugin()
        ]
        #endif
        self.init(plugins: plugins)
    }
    
    
    convenience init(plugins: [PluginType]) {
        let session = Session.default
        session.sessionConfiguration.timeoutIntervalForRequest = 30
        
        self.init(session: session, plugins: plugins)
    }


    init(session: Session, plugins: [PluginType]) {
        
        super.init(session: session, plugins: plugins)
    }
    
    
    
     func request<T>(_ target: Target, callbackQueue: DispatchQueue? = nil) -> Single<T> where T: Codable {

        return rx.request(target, callbackQueue: callbackQueue).map(T.self)
    }
    
    
    func request<T>(_ target: Target, callbackQueue: DispatchQueue? = nil) -> Single<T> where T: HandyJSON {

        return rx.request(target, callbackQueue: callbackQueue).map(T.self)
   }
    
    func request<T: HandyJSON>(_ target: Target, type: T.Type, callbackQueue: DispatchQueue? = nil) -> Single<T> {

        return rx.request(target, callbackQueue: callbackQueue).map(T.self)
   }
}


