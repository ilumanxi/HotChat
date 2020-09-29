//
//  LoginPlugin.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

final class LoginPlugin {
    
    let jsonDecoder = JSONDecoder()
    let tokenKey = "token"
    
}

// MARK: - PluginType
extension LoginPlugin: PluginType {
    
    
    var loginPrefixs: [String] {
        
        return ["login/regist", "login/login", "login/tokenLogin", "login/otherLogin"]
    }
    
    var logoutPrefixs: [String] {
        
        return ["login/quit"]
    }
    
    
    var prefixs: [String] {
        
        return loginPrefixs + logoutPrefixs
    }
    
    
    func willSend(_ request: RequestType, target: TargetType) {
        
        if !shouldHandleRequest(request.request!, prefixs: prefixs) { return }
    }
    
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    
        var request = request
        if LoginManager.shared.isAuthorized, let token = AccessTokenStore.shared.current?.value {
            request.setValue(token, forHTTPHeaderField: tokenKey)
        }
        return request
        
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        
        
        guard case .success(let response)  = result else {
            return
        }
        
        if let json = try? JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String : Any], let code = json["code"] as? CustomStringConvertible, code.description == "-200" {
            LoginManager.shared.logout()
        }
        
        
        if !shouldHandleRequest(response.request!, prefixs: prefixs) { return }
        
        if shouldHandleRequest(response.request!, prefixs: loginPrefixs) {
            handleLogin(response)
        }
        
        
        if shouldHandleRequest(response.request!, prefixs: logoutPrefixs) {
            handleLogout(response)
        }
    }
    
    
    func handleLogin(_ response: Response) {
        
  
        guard let json = String(data: response.data, encoding: .utf8), let result = HotChatResponse<User>.deserialize(from: json) else {
            return
        }
        
        if let user = result.data, result.isSuccessd {
            
            let token = AccessToken(value: user.token)
            
            if user.isInit {
                
            }
            else {
                try? AccessTokenStore.shared.setCurrentToken(token)
            }
        }
    }
    
    func handleLogout(_ response: Response) {
        
        guard let json = String(data: response.data, encoding: .utf8), let result = HotChatResponse<User>.deserialize(from: json) else {
            return
        }
        
//        if result.isSuccessd {
//            LoginManager.shared.logout()
//        }
        
        LoginManager.shared.logout()
    }
    
    func shouldHandleRequest(_ request: URLRequest, prefixs: [String]) -> Bool {
        
        guard  let url = request.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        let path = urlComponents.path.replacingOccurrences(of: "/gateway.php/", with: "")
                
        for prefix in prefixs where path.hasPrefix(prefix) {
            
            return  true
        }
        
        return false
    }
    
}
