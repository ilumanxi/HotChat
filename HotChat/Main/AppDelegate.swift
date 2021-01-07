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
import Toast_Swift
import PKHUD

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
        
        HUD.registerForKeyboardNotifications()
        
        Appearance.default.configure()
        registerANPSNotification(application, didFinishLaunchingWithOptions: launchOptions)
        
        setupWindowRootController()
        
        observeLoginState()
        
        PlatformAuthorization.application(application, didFinishLaunchingWithOptions: launchOptions)
        setupFaceSDK()
       
        appStart()
        appAudit()
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
    
    func appAudit() {
        userSettingsAPI.request(.appAudit, type: Response<AppAudit>.self)
            .verifyResponse()
            .subscribe(onSuccess: { respoonse in
                if let data = respoonse.data{
                    AppAudit.share = data
                }
            }, onError: nil)
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
            selector: #selector(userDidAccountBanned),
            name: .userDidAccountBanned,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tipLogout),
            name: .init(TUIKitNotification_TIMUserStatusListener),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidAccountDestroy),
            name: .userDidAccountDestroy,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTokenInvalid),
            name: .userDidTokenInvalid,
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
    
    @objc func userDidAccountBanned(_ noti: Notification) {
        
        var message = "封号了"
        
        if let msg = noti.userInfo?["resultMsg"] as? String {
            message = msg
        }
        else if let msg = noti.userInfo?["msg"] as? String  {
            message = msg
        }
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [unowned self] _ in
            if self.window?.rootViewController?.isKind(of: UINavigationController.self) ?? false { // 在登录页面
                return
            }
            LoginManager.shared.logout()
        }))
        
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    let logoutAPI = Request<LogoutAPI>()
    
    @objc func userDidAccountDestroy(_ noti: Notification) {
        
        //  {"resultCode":-202,"resultMsg":" 您的账号（25862444）已申请 注销，您已被系统登出 您可以在30天内撤销注销 申请，之后将自动注销 ","userStatus":3,"token":"a217a28f5c1cc64e"}
    
        let message = noti.userInfo?["resultMsg"] as? String ?? "账号注销"
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "撤销注销", style: .default, handler: { [unowned self] _ in
            self.undoAccountDestroy(token: (noti.userInfo?["token"] as? String) ?? "")
        }))
        
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func userDidTokenInvalid(_ noti: Notification) {
        
        let message = noti.userInfo?["msg"] as? String ?? "Token失效"
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {  _ in
            LoginManager.shared.logout()
        }))
        
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func undoAccountDestroy(token: String){
        
        logoutAPI.request(.removeLogout(token: token), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.window?.makeToast(response.msg)
            }, onError: { [unowned self] error in
                self.window?.makeToast(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
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


extension UIApplication {

    /// clearing your app’s launch screen cache on iOS
    /// https://rambo.codes/posts/2019-12-09-clearing-your-apps-launch-screen-cache-on-ios
    func clearLaunchScreenCache() {
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch {
            print("Failed to delete launch screen cache: \(error)")
        }
    }

}
