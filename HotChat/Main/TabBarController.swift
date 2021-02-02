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

class TabBarController: UITabBarController, IndicatorDisplay {
    
    private lazy var customTabBar: TabBar = {
        let tabBar = TabBar()
        tabBar.onComposeButtonDidTapped.delegate(on: self) { (self, _) in
            self.pushPair()
        }
        return tabBar
    }()
    
    override func loadView() {
        super.loadView()
        setupUI()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        observerUnReadCount()
        
        if LoginManager.shared.isAuthorized && !LoginManager.shared.user!.isInit {//更新用户信息
            LoginManager.shared.autoLogin()
        }
    }
    
    func pushPair()  {
        
        guard let navigationController = selectedViewController as? UINavigationController else { return }
        
        let vc = PairsViewController.loadFromStoryboard()
        navigationController.pushViewController(vc, animated: true)
    }
    

    
    func setupUI(){
        setValue(customTabBar, forKey: "tabBar")
        if #available(iOS 13.0, *) {
            let standardAppearance = customTabBar.standardAppearance
            standardAppearance.shadowColor = .clear
            standardAppearance.backgroundColor = .white
            customTabBar.standardAppearance = standardAppearance
        }
        else {
            customTabBar.shadowImage = UIImage(color: UIColor.black.withAlphaComponent(0.1), size: CGSize(width: UIScreen.main.bounds.width, height: 1.0 / 3.0 ))
            customTabBar.barTintColor = .white
            customTabBar.backgroundImage = UIImage(color: .white, size: tabBar.bounds.size)
        }
    }
    
    func observerUnReadCount() {
        
        V2TIMManager.sharedInstance()?.getConversationList(0, count: Int32.max, succ: { [weak self] (list, lastTS, isFinished) in
            self?.onChangeUnReadCount(list)
        }, fail: { (code, error) in
            
        })
        
        NotificationCenter.default.rx.notification(.init(TUIKitNotification_onChangeUnReadCount))
            .subscribe(onNext: { [weak self] noti in
                self?.onChangeUnReadCount(noti.object as? [V2TIMConversation])
            })
            .disposed(by: rx.disposeBag)
    }

    
    func onChangeUnReadCount(_ convList: [V2TIMConversation]?) {
        
        guard let convList = convList else {
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

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let selectIndex = children.firstIndex{ $0 == viewController }!
        
        let tabBarItem = tabBar.items?[selectIndex]
        
        
        ///  UITabBarButton UITabBarSwappableImageView
        if let button = tabBarItem?.value(forKey: "view") as? UIControl, let imageView =  button.subviews.last(where: { $0 is UIImageView }) {
            //  bounceAnimation
            let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
            impliesAnimation.duration = 0.25 * 2
            impliesAnimation.calculationMode = .cubic
            imageView.layer.add(impliesAnimation, forKey: nil)
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
