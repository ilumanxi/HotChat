//
//  TabBarController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/31.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa
import Moya

extension UIWindow {
    
    func setMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController {
            rootViewController = tabBarController
        }
    }
}

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        observerUnReadCount()
        
        if LoginManager.shared.isAuthorized && !LoginManager.shared.user!.isInit {//更新用户信息
            LoginManager.shared.autoLogin()
        }
        
        // 修复消息未读数量显示问题
//        selectedIndex = 2
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//            self.selectedIndex = 0
//        }
    }
    
    func observerUnReadCount() {
        NotificationCenter.default.rx.notification(.init(TUIKitNotification_onChangeUnReadCount))
            .subscribe(onNext: { [weak self] noti in
                self?.onChangeUnReadCount(noti)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func onChangeUnReadCount(_ noti: Notification) {
        
        guard let convList = noti.object as? [V2TIMConversation] else {
            return
        }
        
        let unReadCount = convList
            .compactMap{ $0.unreadCount }
            .reduce(0, +)
        
        let viewController =  viewControllers![2]
        
        if unReadCount == 0 {
            viewController.tabBarItem.badgeValue = nil
        }
        else {
            viewController.tabBarItem.badgeValue = unReadCount.description
        }
    }

}

extension UIWindow {
    static func findKeyWindow() -> UIWindow? {
        if let window = UIApplication.shared.keyWindow, window.windowLevel == .normal {
            // A key window of main app exists, go ahead and use it
            return window
        }
        
        // Otherwise, try to find a normal level window
        let window = UIApplication.shared.windows.first { $0.windowLevel == .normal }
        guard let result = window else {
            Log.print("Cannot find a valid UIWindow at normal level. Current windows: \(UIApplication.shared.windows)")
            return nil
        }
        return result
    }
}

extension UIWindow {
    static var topMost: UIViewController? {
        let keyWindow = UIWindow.findKeyWindow()
        if let window = keyWindow, !window.isKeyWindow {
            Log.print("Cannot find a key window. Making window \(window) to keyWindow. " +
                "This might be not what you want, please check your window hierarchy.")
            window.makeKey()
        }
        guard var topViewController = keyWindow?.rootViewController else {
            Log.print("Cannot find a root view controller in current window. " +
                "Please check your view controller hierarchy.")
            return nil
        }
        
        while let currentTop = topViewController.presentedViewController {
            topViewController = currentTop
        }
        
        return topViewController
    }
}
