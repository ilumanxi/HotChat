//
//  ForgotPasswordProtocols.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya


protocol ForgotPasswordAPI {
    
    func sendCode(_ phone: String) -> Single<HotChatResponseEmptyDataType>
    func resetPassword(_ phone: String, password: String, code: String) -> Single<HotChatResponseEmptyDataType>
}


class ForgotPasswordDefaultAPI: ForgotPasswordAPI {
        
    static let share = ForgotPasswordDefaultAPI()
    
    
    let API  = RequestAPI<AccountAPI>()
    
    func sendCode(_ phone: String) -> Single<HotChatResponseEmptyDataType> {
        
        return API.request(.sendCode(phone:phone, type: .resetPassword))
    }
    
    func resetPassword(_ phone: String, password: String, code: String) -> Single<HotChatResponseEmptyDataType> {
        return API.request(.resetPassword(phone: phone, password: password, code: code))
    }
}
