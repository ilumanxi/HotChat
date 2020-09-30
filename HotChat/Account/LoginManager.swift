//
//  LoginManager.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation

typealias TokenType = LoginManager.Parameters.TokenIdentifier

class LoginManager {
    
    
    static let shared = LoginManager()
    
    enum Parameters {
        
        enum TokenIdentifier: Int { // Token登陆类型 1app启动登陆 2微信登陆 3苹果登陆
            case launch = 1
            case weChat = 2
            case apple = 3
        }
        
        case phone(phone: String, password: String)
        case token(token: String, tokenType: TokenIdentifier)
        
    }

    
    var user: User?
    
    private init() {}
    
    /// Checks and returns whether the user was authorized and an access token exists locally. This method
    /// does not check whether the access token has been expired. To verify an access token, use the
    /// `API.Auth.verifyAccessToken` method.
    public var isAuthorized: Bool {
        return AccessTokenStore.shared.current != nil
    }
    
    
    func login(token: AccessToken) {
        try! AccessTokenStore.shared.setCurrentToken(token)
        NotificationCenter.default.post(name: .userDidLogin, object: token)
    }
    
    
    func logout() {
        try! AccessTokenStore.shared.removeCurrentAccessToken()
        user = nil
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
}
