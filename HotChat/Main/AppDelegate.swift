//
//  AppDelegate.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import AuthenticationServices
import SwiftyStoreKit
import Bugly
import Toast_Swift
import PKHUD
import RangersAppLog
import URLNavigator
import UMVerify




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let userSettingsAPI = Request<UserSettingsAPI>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
    
        // Initialize navigation map
        NavigationMap.initialize(navigator: Navigator.share)
        
        setupTrack()
        setupUMVerify()
        
        Bugly.start(withAppId: nil)
        
        setupIM()
        
        HUD.registerForKeyboardNotifications()
        
        Appearance.default.configure()
        registerANPSNotification(application, didFinishLaunchingWithOptions: launchOptions)
        
        setupWindowRootController(launchOptions: launchOptions)
        
        observeLoginState()
        
        PlatformAuthorization.application(application, didFinishLaunchingWithOptions: launchOptions)
        setupFaceSDK()
       
        appStart()
        appAudit()
        store()
        
        return true
    }
    
    func store()  {
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
    }
    
    func setupUMVerify() {
        
        UMConfigure.initWithAppkey(Constant.UMVerify.appkey, channel: "App Store");
        UMCommonHandler.setVerifySDKInfo(Constant.UMVerify.info) { info in
            Log.print("UMVerify: \(info)")
        }
        
        UMCommonHandler.accelerateVerify(withTimeout: 3) { info in
            Log.print("UMVerify: \(info)")
        }
        
        UMCommonHandler.accelerateVerify(withTimeout: 3) { info in
            Log.print("UMVerify: \(info)")
        }
        #if DEBUG
        UMConfigure.setLogEnabled(true)
        #endif
    }
    
    func setupTrack()  {
        let config = BDAutoTrackConfig()
        config.serviceVendor = .CN
        config.appID = 211417.description
        config.appName = "tanliaoios"
        config.channel = "App Store"
        
        #if DEBUG
        config.showDebugLog = true
        config.logNeedEncrypt = false
        #else
        config.showDebugLog = false
        config.logNeedEncrypt = true
        #endif
        
        
        BDAutoTrack.start(with: config)
    }
    
    func setupIM()  {
        
        #if DEBUG
        TUIKit.sharedInstance()?.setup(withAppId: Constant.IM.appID, logLevel: .LOG_NONE)
        #else
        TUIKit.sharedInstance()?.setup(withAppId: Constant.IM.appID, logLevel: .LOG_NONE)
        #endif
        
        let config = TUIKitConfig.default()!
        config.avatarType = .TAvatarTypeRounded
        
        CallManager.shareInstance()?.initCall()
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
    
    func setupWindowRootController(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        if LoginManager.shared.isAuthorized {
            window.setMainViewController()
            if let _ = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.jumpChat()
                }
            }
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
        
        tpns()
    }
    
    func setupFaceSDK() {

        BDFaceBaseViewController.setupFaceSDK()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Try presenting the URL first
        
        if Navigator.share.pushURL(url) != nil {
          print("[Navigator] push: \(url)")
          return true
        }
        else if Navigator.share.present(url, wrap: UINavigationController.self) != nil {
          print("[Navigator] present: \(url)")
          return true
        }
        // Try opening the URL
        else if Navigator.share.open(url) == true {
          print("[Navigator] open: \(url)")
          return true
        }

        return PlatformAuthorization.application(app, open: url, options: options)
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return PlatformAuthorization.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        LoginManager.shared.deviceToken = deviceToken
        
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

extension AppDelegate: XGPushDelegate {
    
    func tpns() {
        /// 控制台打印TPNS日志，开发调试建议开启
        XGPush.defaultManager().isEnableDebug = true;
        
        /// 自定义通知栏消息行为，有自定义消息行为需要使用
        // setNotificationConfigure()

        /// 非广州集群，请开启对应集群配置（广州集群无需使用），此函数需要在startXGWithAccessID函数之前调用
        // configHost()
        
        
        XGPush.defaultManager().startXG(withAccessID: Constant.TPNS.accessID, accessKey: Constant.TPNS.accessKey, delegate: self)
        
        if XGPush.defaultManager().xgApplicationBadgeNumber > 0 {
            XGPush.defaultManager().xgApplicationBadgeNumber = 0
        }
    }
    
    /// 自定义通知栏消息行为（无自定义需求无需使用）
    func setNotificationConfigure() {
        let action1 = XGNotificationAction.action(withIdentifier: "xgaction001", title: "xgAction1", options: .none)
        let action2 = XGNotificationAction.action(withIdentifier: "xgaction002", title: "xgAction2", options: .destructive)
        
        if let act1 = action1, let act2 = action2 {
            if let category = XGNotificationCategory.category(withIdentifier: "xgCategory", actions: [act1, act2], intentIdentifiers: [], options: XGNotificationCategoryOptions.init(rawValue: 0)) as? AnyHashable {
                if let configure = XGNotificationConfigure.init(notificationWithCategories: Set([category]), types: [.alert, .badge, .sound]) {
                    XGPush.defaultManager().notificationConfigure = configure
                }
            }
        }
    }
    
    /// 注册推送服务成功回调
    /// @param deviceToken APNs 生成的Device Token
    /// @param xgToken TPNS 生成的 Token，推送消息时需要使用此值。TPNS 维护此值与APNs 的 Device Token的映射关系
    /// @param error 错误信息，若error为nil则注册推送服务成功
    func xgPushDidRegisteredDeviceToken(_ deviceToken: String?, xgToken: String?, error: Error?) {
        
        let msg = NSLocalizedString("register_app", comment: "") + (error == nil ? NSLocalizedString("success", comment: "") : NSLocalizedString("fail", comment: "") + String(describing: error))
        Log.print(msg)
    }
    
    /// 注销推送服务回调
    func xgPushDidFinishStop(_ isSuccess: Bool, error: Error?) {
        let msg = NSLocalizedString("unregister_app", comment: "") + (error == nil ? NSLocalizedString("success", comment: "") : NSLocalizedString("fail", comment: "") + String(describing: error))
        Log.print(msg)
    }
    
    /// 统一接收消息回调
    func xgPushDidReceiveRemoteNotification(_ notification: Any, withCompletionHandler completionHandler: ((UInt) -> Void)? = nil) {
        if notification is Dictionary<String, Any> {
            Log.print(notification)
            completionHandler?(UIBackgroundFetchResult.newData.rawValue)
        } else if notification is UNNotification {
            Log.print(notification)
            let options = UNNotificationPresentationOptions(arrayLiteral: [.alert, .badge, .sound])
            completionHandler?(options.rawValue)
        }
    }
    
    /// 统一点击回调
    /// @param response 如果iOS 10+/macOS 10.14+则为UNNotificationResponse，低于目标版本则为NSDictionary
    func xgPushDidReceiveNotificationResponse(_ response: Any, withCompletionHandler completionHandler: @escaping () -> Void) {
        jumpChat()
        completionHandler()
    }
    
    func jumpChat() {
        Thread.safeAsync {
            if let tabBarController = self.window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 2
            }
        }
    }
    
    /// 角标设置回调
    func xgPushDidSetBadge(_ isSuccess: Bool, error: Error?) {
        let msg = NSLocalizedString("badge_section", comment: "") + (error == nil ? NSLocalizedString("success", comment: "") : NSLocalizedString("fail", comment: "") + String(describing: error))
        Log.print(msg)
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
