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
    case phoneBinding = 5
    case accountDestroy = 6
}

enum AccountAPI {
    case sendCode(phone: String, type: CodeType)
    case signUp(phone: String, password: String, code: String)
    case phoneSignin(phone: String, password: String)
    case tokenSignin(token: String)
    case otherSignin(code: String, type: Int)
    case logout
    case resetPassword(phone: String, password: String, code: String)
    case editUser(headPic: String, sex: Int, nick: String, birthday: Int)
    case labelList
    case recommendList
}

extension AccountAPI: TargetType {


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
        case .logout:
            return "login/quit"
        case .recommendList:
            return "login/recommendList"
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
        let parameters: [String : Any]
        
        switch self {
        case .sendCode(let phone, let type):
            parameters = [
                "phone": phone,
                "type": type.rawValue
            ]
        case .signUp(phone: let phone, password: let password, code: let code):
            parameters = [
                "phone": phone,
                "password": password.md5(),
                "verifyCode" : code,
                "timeStamp" : Int(Date().timeIntervalSince1970)
            ]
        case .phoneSignin(phone: let phone, password: let password):
            parameters = [
                "phone": phone,
                "password": password.md5(),
                "timeStamp" : Int(Date().timeIntervalSince1970)
            ]
        case .resetPassword(phone: let phone, password: let password, code: let code):
            parameters = [
                "phone": phone,
                "password": password.md5(),
                "verifyCode" : code,
                "timeStamp" : Int(Date().timeIntervalSince1970)
            ]
        case .tokenSignin(token: let token):
            parameters = [
                "token": token
            ]
        case .otherSignin(code: let code, type: let type):
            if let channelId = Constant.pushChannelId {
                parameters = [
                    "code" : code,
                    "type" : type,
                    "channelId" : channelId
                ]
            }
            else {
                parameters = [
                    "code": code,
                    "type": type,
                ]
            }
        case .editUser(headPic: let headPic, sex: let sex, nick: let nick, birthday: let birthday):
            parameters = [
                "headPic" : headPic,
                "sex" : sex,
                "nick" : nick,
                "birthday" : birthday
            ]
        case .labelList:
            parameters = [:]
        case .logout:
            parameters = [:]
        case .recommendList:
            parameters = [:]
        }
        
        let encoding: ParameterEncoding = (self.method == .post) ? JSONEncoding.default : URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
            
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
    
}
