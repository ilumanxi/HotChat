//
//  AccountProtocols.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

enum SignupState {
    case signedUp(signedUp: Bool)
}

protocol SignupAPI {
    
    func sendCode(_ phone: String) -> Single<HotChatResponseEmptyDataType>
    func signup(_ phone: String, password: String, code: String) -> Single<HotChatResponseEmptyDataType>
}


protocol ValidationService {
    func validatePhone(_ phone: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult
    func validateCode(_ code: String) -> ValidationResult
}



class SignupDefaultAPI: SignupAPI {
    
    static let share = SignupDefaultAPI()
    
    let API  = RequestAPI<Account>()
    
    func sendCode(_ phone: String) -> Single<HotChatResponseEmptyDataType> {
        return API.request(.sendCode(phone: phone, type: .signUp))
    }
    
    func signup(_ phone: String, password: String, code: String) -> Single<HotChatResponseEmptyDataType> {
        return API.request(.signUp(phone: phone, password: password, code: code))
    }
}


class DefaultValidationService: ValidationService {

    let minPasswordCount = 4
    
    let maxPasswordCount = 12
    
    let phoneCount = 11
    
    static let share = DefaultValidationService()
    
    func validatePhone(_ phone: String) -> ValidationResult {
        if phone.isEmpty {
            return .failed(message: "手机号不能为空")
        }
//        else if phone.count != phoneCount {
//            return .failed(message: "手机号必须\(phoneCount)位")
//        }
        return .ok(message: "")
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .failed(message: "密码不能为空")
        }
//        else if !(password.length >= minPasswordCount &&  password.length <= maxPasswordCount) {
//            return .failed(message: "密码长度\(minPasswordCount)-\(maxPasswordCount)位")
//        }
        return .ok(message: "")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        
        if password != repeatedPassword {
            return .failed(message: "两次密码不一致")
        }
        
        return .ok(message: "")
    }
    
    func validateCode(_ code: String) -> ValidationResult {
        if code.isEmpty {
            return .failed(message: "验证码不能为空")
        }
        return .ok(message: "")
    }
    
}
