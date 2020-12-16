//
//  AppDelegate.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import AuthenticationServices
import SYBPush_normal
import SwiftyStoreKit
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let userSettingsAPI = Request<UserSettingsAPI>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Bugly.start(withAppId: nil)
        TUIKit.sharedInstance()?.setup(withAppId: Constant.IMAppID, logLevel: .LOG_NONE)
        let config = TUIKitConfig.default()!
        config.avatarType = .TAvatarTypeRounded
        
        CallManager.shareInstance()?.initCall()
        
        
        
        Appearance.default.configure()
        registerANPSNotification(application, didFinishLaunchingWithOptions: launchOptions)
        
        setupWindowRootController()
        
        observeLoginState()
        
        PlatformAuthorization.application(application, didFinishLaunchingWithOptions: launchOptions)
        setupFaceSDK()
       
        appStart()
        
        // see notes below for the meaning of Atomic / Non-Atomic
            SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            // Deliver content from server, then:
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        // Unlock content
                    case .failed, .purchasing, .deferred:
                        break // do nothing
                    @unknown default:
                        print("@unknown default")
                    }
                }
            }
        
        return true
    }
    
    func appStart() {
        userSettingsAPI.request(.appStart, type: ResponseEmpty.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func setupWindowRootController() {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        if LoginManager.shared.isAuthorized {
            window.setMainViewController()
            LoginManager.shared.autoLogin()
        }
        else {
            window.setLoginViewController()
        }
          
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    @available(iOS 13.0, *)
    func observeAppleSignInState() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSignInWithAppleStateChanged(notification:)),
            name: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil
        )
    }
    
    
    
    @objc func observeLoginState() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogin),
            name: .userDidLogin,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogout),
            name: .userDidLogout,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidBanned),
            name: .userDidBanned,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tipLogout),
            name: .init(TUIKitNotification_TIMUserStatusListener),
            object: nil
        )
        
        if #available(iOS 13.0, *) {
            observeAppleSignInState()
        }
    }
    
    
    @objc func tipLogout() {
        
        let alertController = UIAlertController(title: "下线通知", message: "你的账号于另一台手机上登录。", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            LoginManager.shared.logout()
        }))
        UIWindow.topMost?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func userDidLogin(_ noti: Notification) {
        window?.setMainViewController()
    }
    
    @objc func userDidLogout(_ noti: Notification) {
        window?.setLoginViewController()
    }
    
    @objc func userDidBanned(_ noti: Notification) {
    
        let message = noti.userInfo?["msg"] as? String ?? "封号了"
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
            LoginManager.shared.logout()
        }))
        
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    
    @objc
    func handleSignInWithAppleStateChanged(notification: Notification) {
        // Sign the user out, optionally guide them to sign in again
        window?.setLoginViewController()
    }
    
    
    func registerANPSNotification(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
       let notificationCenter =  UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                Thread.safeAsync {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        BPush.registerChannel(
            launchOptions, apiKey: "ApjAMhQwbBbeGfku2ecVe1DO",
            pushMode: .development,
            withFirstAction: "launchAction",
            withSecondAction: "close",
            withCategory: "HotChat",
            useBehaviorTextInput: true,
            isDebug: false
        )
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String : Any]  {
            BPush.handleNotification(userInfo)
        }
        
        BPush.disableLbs()
    }
    
    func setupFaceSDK() {

        BDFaceBaseViewController.setupFaceSDK()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        return PlatformAuthorization.application(app, open: url, options: options)
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return PlatformAuthorization.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        LoginManager.shared.deviceToken = deviceToken
        BPush.registerDeviceToken(deviceToken)
        BPush.bindChannel { result, error in
            
            // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
            
            if let _ = error { return }
            
            if let json = result as? [String : Any], let code = json[BPushRequestErrorCodeKey] as? Int, code == 0 {
                return
            }
            
            BPush.setTag("tag") { result, error in
                
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
//        if let viewContoller = self.window?.visibleViewController, viewContoller.conforms(to: Autorotate.self) { //  allButUpsideDown
//            return viewContoller.supportedInterfaceOrientations
//        }
        
        return .portrait
    }

}
