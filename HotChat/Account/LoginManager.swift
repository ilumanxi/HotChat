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
    
}

class LoginManager: NSObject {
    
    
    @objc static let shared = LoginManager()
    
    enum Parameters {
        
        enum TokenIdentifier: Int { // Token登陆类型 1app启动登陆 2微信登陆 3苹果登陆
            case launch = 1
            case weChat = 2
            case apple = 3
        }
        
        case phone(phone: String, password: String)
        case token(token: String, tokenType: TokenIdentifier)
        
    }
    

    lazy var storage: Storage<String> = {
        let diskConfig = DiskConfig(name: "UserCache")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        let transformer = TransformerFactory.forCodable(ofType: String.self)
        let storage = try! Storage<String>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: transformer)
        return storage
    }()

    
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
        
        TUIKit.sharedInstance()?.login(user.userId, userSig: user.imUserSig, succ: {
            TUILocalStorage.sharedInstance().saveLogin(user.userId, withAppId: UInt(IM.appID), withUserSig: user.imUserSig)
        }, fail: { (code, msg) in
            Log.print("检查IM配置是否正确: \(code) \(String(describing: msg))")
        })

        if sendNotification {
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
        }
    }
    
    func update(user: User){
        self.user = user
        try! storage.setObject( user.toJSONString()!, forKey: userCacheKey)
        NotificationCenter.default.post(name: .userDidChange, object: nil, userInfo: nil)
    }
    
    func autoLogin() {
        guard let user = LoginManager.shared.user else {
            return
        }
        
        TUILocalStorage.sharedInstance().login { (userID, appId, userSig) in
            if appId == IM.appID && !userID.isEmpty && !userSig.isEmpty {
                TUIKit.sharedInstance()?.login(userID, userSig: userSig, succ: {
                    
                }, fail: { (code, msg) in
                    Log.print("检查IM配置是否正确: \(code) \(String(describing: msg))")
                })
            }
        }
        
        SigninDefaultAPI.share.signin(user.token)
            .checkResponse()
            .subscribe(onSuccess:{ [weak self] response in
                self?.update(user: response.data!)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
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
