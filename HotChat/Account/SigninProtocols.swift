//
//  SigninProtocols.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya


protocol SigninAPI {
    
    func signin(_ phone: String, password: String) -> Single<HotChatResponse<User>>
    
    func signin(_ token: String) -> Single<HotChatResponse<User>>
    
    func signin(_ code: String, type: Int) -> Single<HotChatResponse<User>>
}


class SigninDefaultAPI: SigninAPI {

    static let share = SigninDefaultAPI()
    
    let API  = RequestAPI<Account>()
    
    func signin(_ phone: String, password: String) -> Single<HotChatResponse<User>> {
        return API.request(.phoneSignin(phone: phone, password: password))
    }
    
    func signin(_ token: String) -> Single<HotChatResponse<User>> {
        return API.request(.tokenSignin(token: token))
    }
    
    func signin(_ code: String, type: Int) -> Single<HotChatResponse<User>> {
        return API.request(.otherSignin(code: code, type: type))
    }
}
