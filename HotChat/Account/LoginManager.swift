//
//  LoginManager.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Cache
import RxCoreLocation

typealias TokenType = LoginManager.Parameters.TokenIdentifier

extension Notification.Name {
    
    static let userDidChange = NSNotification.Name("com.friday.Chat.userDidChange")
    
    static let appApprovedDidChange = NSNotification.Name("com.friday.Chat.appVersionApprovedDidChange")
    
}

class LoginManager: NSObject {
    
    @objc static let shared = LoginManager()
    
    enum Parameters {
        
        enum TokenIdentifier: Int { // Token登陆类型 1app启动登陆 2微信登陆 3苹果登陆 4友盟手机登录
            case launch = 1
            case weChat = 2
            case apple = 3
            case um = 4
        }
        
        case phone(phone: String, password: String)
        case token(token: String, tokenType: TokenIdentifier)
        
    }
    

    lazy var storage: Storage<String, String> = {
        let diskConfig = DiskConfig(name: "UserCache")
        let memoryConfig = MemoryConfig(expiry: .never)
        let transformer = TransformerFactory.forCodable(ofType: String.self)
        let storage = try! Storage<String, String>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: transformer)
        return storage
    }()

    var deviceToken: Data?
    
    @objc private(set) var user: User?
    
    let manager = CLLocationManager()
    
    private(set) var location: CLLocation?
    
    let userSettingsAPI = Request<UserSettingsAPI>()
    
    func getLocation(block: @escaping (CLLocation?) -> Void) {
        
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        manager.rx
            .location
            .subscribe(onNext: { [weak self] location in

                self?.manager.stopUpdatingLocation()
                if let location = location {
                    self?.location = location
                    self?.uploadLocation(location)
                }
                block(location)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func uploadLocation (_ location: CLLocation) {
        userSettingsAPI.request(.location(location), type: ResponseEmpty.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    private let userCacheKey = "sharedUser"
    
    private override init() {
        super.init()
        let json = try? self.storage.object(forKey: userCacheKey)
        self.user = User.deserialize(from: json)
    }
    
    /// Checks and returns whether the user was authorized and an access token exists locally. This method
    /// does not check whether the access token has been expired. To verify an access token, use the
    /// `API.Auth.verifyAccessToken` method.
    public var isAuthorized: Bool {
        return user != nil
    }
    

    func login(user: User, sendNotification: Bool) {
        self.user = user
        try! storage.setObject( user.toJSONString()!, forKey: userCacheKey)
        
        imLogin(userID: user.userId, appId: UInt(Constant.IM.appID), userSig: user.imUserSig)

        if sendNotification {
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
        }
    }
    
    func autoLogin() {
        guard let user = LoginManager.shared.user else {
            return
        }
        
        TUILocalStorage.sharedInstance().login { (userID, appId, userSig) in
            if appId == Constant.IM.appID && !userID.isEmpty && !userSig.isEmpty {
                self.imLogin(userID: userID, appId: appId, userSig: userSig)
            }
        }
        
        SigninDefaultAPI.share.signin(user.token)
            .verifyResponse()
            .subscribe(onSuccess:{ [weak self] response in
                self?.update(user: response.data!)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func imLogin(userID: String, appId: UInt, userSig: String) {
        
        if V2TIMManager.sharedInstance()!.getLoginStatus() != .STATUS_LOGOUT {
            Log.print("IM: 已登录，尝试登录")
            return
        }
        
        TUIKit.sharedInstance()?.login(userID, userSig: userSig, succ: {
            TUILocalStorage.sharedInstance().saveLogin(userID, withAppId:appId, withUserSig: userSig)
            self.setAPNS()
        }, fail: { (code, msg) in
            Log.print("检查IM配置是否正确: \(code) \(String(describing: msg))")
        })
    }
    
    
    private func setAPNS() {
        if let deviceToken = self.deviceToken {
            let config = V2TIMAPNSConfig()
            config.businessID = Constant.IM.businessID
            config.token = deviceToken
            
            V2TIMManager.sharedInstance()?.setAPNS(config, succ: {
                Log.print("设置 IM APNS 成功")
            }, fail: { (code, msg) in
                Log.print("设置 APNS 失败: \(code)  \(msg ?? "")")
            })
        }
    }
    
    @objc func update(user: User) {
        if user.token.isEmpty {
            user.token = [self.user?.token ?? "", user.token].first{ !$0.isEmpty } ?? ""
            user.imUserSig = [self.user?.imUserSig ?? "", user.imUserSig].first{ !$0.isEmpty } ?? ""
            user.isInit = [self.user?.isInit ?? false, user.isInit].contains(true)
        }
        
        self.user = user
        try! storage.setObject( user.toJSONString()!, forKey: userCacheKey)
        NotificationCenter.default.post(name: .userDidChange, object: nil, userInfo: nil)
    }
    
    func logout() {
        user = nil
        try? storage.removeObject(forKey: userCacheKey)
        
        V2TIMManager.sharedInstance()?.logout({
            TUILocalStorage.sharedInstance().logout()
        }, fail: { (_, _) in
            Log.print("IM 退出登录失败")
        })
        
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
}
