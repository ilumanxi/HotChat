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
    
    func sendCode(_ phone: String) -> Single<ResponseEmpty>
    func resetPassword(_ phone: String, password: String, code: String) -> Single<ResponseEmpty>
}


class ForgotPasswordDefaultAPI: ForgotPasswordAPI {
        
    static let share = ForgotPasswordDefaultAPI()
    
    
    let API  = RequestAPI<AccountAPI>()
    
    func sendCode(_ phone: String) -> Single<ResponseEmpty> {
        
        return API.request(.sendCode(phone:phone, type: .resetPassword))
    }
    
    func resetPassword(_ phone: String, password: String, code: String) -> Single<ResponseEmpty> {
        return API.request(.resetPassword(phone: phone, password: password, code: code))
    }
}
