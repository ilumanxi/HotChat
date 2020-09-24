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
    case editUser(headPic: String, sex: Int, nick: String, birthday: Int)
    case labelList
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
        case .editUser:
            return "login/editUser"
        case .labelList:
            return "login/labelList"
        }

    }
    
    var method: Moya.Method {
        switch self {
        case .sendCode:
            return .get
        default:
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
                "password": password.md5(),
                "timeStamp" : Int(Date().timeIntervalSince1970)
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .resetPassword(phone: let phone, password: let password, code: let code):
            let params: [String : Any] = [
                "phone": phone,
                "password": password.md5(),
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
        case .editUser(headPic: let headPic, sex: let sex, nick: let nick, birthday: let birthday):
            let params: [String : Any] = [
                "headPic" : headPic,
                "sex" : sex,
                "nick" : nick,
                "birthday" : birthday
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .labelList:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        }
            
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
    
}
