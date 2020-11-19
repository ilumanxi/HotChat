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


struct ResponseStateType: HandyJSON, State {
    
    var faceCode: Int = 0
    
    var msg: String = ""
    
    /// 通用
    var resulutCode: Int = 0
    var resulutMsg: String = ""
    
    var isSuccessd: Bool {
        
        let codes = [faceCode, resulutCode]
        let flag = codes.first {  $0 == 1  } ?? 0
        return flag == 1
    }
    
    var error: Error? {
        
        if isSuccessd {
            return nil
        }
        
        let msgs = [msg, resulutMsg]
        
        let errorDescription = msgs.first { !$0.isEmpty } ?? "未知错误"
        
        return NSError(domain: "HotChatError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorDescription])
    }
    
}

typealias ResponseEmpty = Response<ResponseEmptyType>

typealias ResponseState = Response<ResponseStateType>

protocol State {
    
    var isSuccessd: Bool { get }
    var error: Error? { get }
}

struct Response<T: HandyJSON>: HandyJSON, State {

    var code: Int!
    var msg: String = ""
    
    var data: T?
    
    var isSuccessd: Bool {
        if let data = data, let state = data as?  State {
            return state.isSuccessd
        }
         return code == 1
    }
    
    var error: Error? {

        if let data = data, let state = data as?  State,  let error = state.error  {
            return error
        }
        
        if isSuccessd {
            return nil
        }
        
        return NSError(domain: "HotChatError", code: 1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}


extension NSError {
    
    var localizedDescription: String {
        return userInfo[NSLocalizedDescriptionKey] as! String
    }
}

extension ObservableType {

    func verifyResponse() -> RxSwift.Observable<Self.Element> where Self.Element: State {
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

    func verifyResponse() -> RxSwift.Single<Self.Element> where Self.Element: State  {
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
