//
//  Account.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/15.
//  Copyright © 2020 风起兮. All rights reserved.
//


import Foundation
import Moya
import CryptoSwift


enum CodeType: Int {
    case signIn = 3
    case signUp = 1
    case resetPassword = 2
}

enum Account {
    case sendCode(phone: String, type: CodeType)
    case signUp(phone: String, password: String, code: String)
    case phoneSignin(phone: String, password: String)
    case tokenSignin(token: String)
    case otherSignin(code: String, type: Int)
    case resetPassword(phone: String, password: String, code: String)
}

extension Account: TargetType {


    var baseURL: URL {
        return Constant.APIHostURL
    }
    
    var path: String {
        switch self {
        case .sendCode:
            return "login/sendCode"
        case .signUp:
            return "login/regist"
        case .phoneSignin:
            return "login/login"
        case .tokenSignin:
            return "login/tokenLogin"
        case .otherSignin:
            return "login/otherLogin"
        case .resetPassword:
            return "login/resetPsd"
        }

    }
    
    var method: Moya.Method {
        switch self {
        case .sendCode:
            return .get
        case  .signUp, .phoneSignin, .tokenSignin, .otherSignin, .resetPassword:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .sendCode(let phone, let type):
            let params: [String : Any] = [
                "phone": phone,
                "type": type.rawValue
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .signUp(phone: let phone, password: let password, code: let code):
            let params: [String : Any] = [
                "phone": phone,
                "password": password.md5(),
                "verifyCode" : code,
                "timeStamp" : Int(Date().timeIntervalSince1970)
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .phoneSignin(phone: let phone, password: let password):
            
            let params: [String : Any] = [
                "phone": phone,
                "password": password.data(using: .utf8)!.base64EncodedString(),
                "timeStamp" : Int(Date().timeIntervalSince1970)
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .resetPassword(phone: let phone, password: let password, code: let code):
            let params: [String : Any] = [
                "phone": phone,
                "password": password.data(using: .utf8)!.base64EncodedString(),
                "verifyCode" : code,
                "timeStamp" : Int(Date().timeIntervalSince1970)
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .tokenSignin(token: let token):
            let params: [String : Any] = [
                "token": token
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .otherSignin(code: let code, type: let type):
            var params: [String : Any] = [
                "code": code,
                "type": type,
            ]
            
            if let channelId = Constant.pushChannelId {
                params["channelId"] = channelId
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
            
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
    
}
