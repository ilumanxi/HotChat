//
//  LoginPlugin.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya

/*
 
 deviceType:操作系统：1安卓 2 IOS
 appVersion:app版本
 phoneModel:手机型号
 longitude：地理位置：经度
 latitude：地理位置：纬度
 channelId:推送设备ID


 */

final class AccountPlugin {
    
    let jsonDecoder = JSONDecoder()
    let tokenKey = "token"
    
}

// MARK: - PluginType
extension AccountPlugin: PluginType {
    
    
    var signInPrefixs:  [String] { //  手机注册 、 其他注册
        return ["login/regist", "login/otherLogin"]
    }
    
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
        
//        if !shouldHandleRequest(request.request!, prefixs: prefixs) { return }
    }
    
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    
        return setHTTPHeaderFields(request)
        
    }
    
    func setHTTPHeaderFields(_ request: URLRequest) -> URLRequest {
        var request = request
        request.setValue(Bundle.main.appVersion, forHTTPHeaderField: "appVersion")
        var systemInfo = utsname()
        uname(&systemInfo)
               
        let phoneModel = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        
        request.setValue(phoneModel, forHTTPHeaderField: "phoneModel")
        
        request.setValue(Constant.pushChannelId, forHTTPHeaderField: "channelId")
        
        request.setValue("2", forHTTPHeaderField: "deviceType")
        
        if let token = LoginManager.shared.user?.token {
            request.setValue(token, forHTTPHeaderField: tokenKey)
        }
        
        if let location = LoginManager.shared.location {
            
            request.setValue(location.coordinate.longitude.description, forHTTPHeaderField: "longitude")
            request.setValue(location.coordinate.latitude.description, forHTTPHeaderField: "latitude")
            
        }

        
        return request
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
        
        guard case .success(let response)  = result else {
            return
        }
        
        if let json = try? JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String : Any], let code = json["code"] as? CustomStringConvertible {
            
            if code.description == "-200" { // token失效
                LoginManager.shared.logout()
            }
            else if code.description == "-201" { // 封号
                NotificationCenter.default.post(name: .userDidBanned, object: nil, userInfo: json)
            }
        }
        
//        if !shouldHandleRequest(response.request!, prefixs: prefixs) { return }
        
        if shouldHandleRequest(response.request!, prefixs: signInPrefixs) {
            handleSignIn(response)
        }
        
        if shouldHandleRequest(response.request!, prefixs: loginPrefixs) {
            handleLogin(response)
        }
        
        if shouldHandleRequest(response.request!, prefixs: logoutPrefixs) {
            handleLogout(response)
        }
    }
    
    func handleSignIn(_ response: Moya.Response) {
        
        guard let json = String(data: response.data, encoding: .utf8), let result = Response<User>.deserialize(from: json) else {
            return
        }
        
        if result.isSuccessd, let user = result.data, user.isInit == false {
            NotificationCenter.default.post(name: .userDidSignedUp, object: nil, userInfo: nil)
        }
    }
    
    
    func handleLogin(_ response: Moya.Response) {
        
  
        guard let json = String(data: response.data, encoding: .utf8), let result = Response<User>.deserialize(from: json) else {
            return
        }
        
        if let user = result.data, result.isSuccessd {
            
            LoginManager.shared.login(user: user,sendNotification: user.isInit)
        }
    }
    
    func handleLogout(_ response: Moya.Response) {
        
//        guard let json = String(data: response.data, encoding: .utf8), let result = HotChatResponse<User>.deserialize(from: json) else {
//            return
//        }
        
//        if result.isSuccessd {
//            LoginManager.shared.logout()
//        }
        
        LoginManager.shared.logout()
    }
    
    func shouldHandleRequest(_ request: URLRequest, prefixs: [String]) -> Bool {
        
        guard  let url = request.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        let path = urlComponents.path
                
        for prefix in prefixs where path.contains(prefix) {
            
            return  true
        }
        
        return false
    }
    
}
