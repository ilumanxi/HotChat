//
//  HotChatResponse.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import HandyJSON
import RxSwift

struct ResponseEmptyType: HandyJSON {
    
}

typealias ResponseEmpty = Response<ResponseEmptyType>

protocol State {
    
    var isSuccessd: Bool { get }
    var error: Error? { get }
}

struct Response<T: HandyJSON>: HandyJSON, State {

    var code: Int!
    var msg: String = ""
    
    var data: T?
    
    var isSuccessd: Bool {
         return code == 1
    }
    
    var error: Error? {
        if isSuccessd {
            return nil
        }
        return HotChatError.generalError(reason: .conversionError(string: msg, encoding: .utf8))
    }
}


extension ObservableType {

    func checkResponse() -> RxSwift.Observable<Self.Element> where Self.Element: State {
        return map {
            if $0.isSuccessd {
                return $0
            }
            else {
                throw $0.error!
            }
        }
    }
}


extension PrimitiveSequenceType where Self.Trait == RxSwift.SingleTrait {

    func checkResponse() -> RxSwift.Single<Self.Element> where Self.Element: State  {
        return map {
            if $0.isSuccessd {
                return $0
            }
            else {
                throw $0.error!
            }
        }
    }
}
