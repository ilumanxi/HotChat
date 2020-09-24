//
//  AppDelegate.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SYBPush


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        Appearance.default.configure()
        
        PlatformAuthorization.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        registerANPSNotification(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
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
            withCategory: "Test",
            useBehaviorTextInput: true,
            isDebug: true
        )
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String : Any]  {
            BPush.handleNotification(userInfo)
        }
        
        BPush.disableLbs()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        return PlatformAuthorization.application(app, open: url, options: options)
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return PlatformAuthorization.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        BPush.registerDeviceToken(deviceToken)
        BPush.bindChannel { result, error in
            
            // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
            
            if let _ = error { return }
            
            if let json = result as? [String : Any], let code = json[BPushRequestErrorCodeKey] as? Int, code == 0 {
                return
            }
            
            BPush.setTag("tag") { result, error in
                debugPrint(String(describing: result))
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if let viewContoller = self.window?.visibleViewController, viewContoller.conforms(to: Autorotate.self) { //  allButUpsideDown
            return viewContoller.supportedInterfaceOrientations
        }
        
        return .portrait
    }

}
