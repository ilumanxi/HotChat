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
        
        observeLoginState()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        handleLogin()
    }
    
    @objc func handleLogin() {
        
        if LoginManager.shared.isAuthorized {
            let token = AccessTokenStore.shared.current!.value
            SigninDefaultAPI.share.signin(token)
                .subscribe(onSuccess:{ result in
                    Log.print(result)
                }, onError: { error in
                    Log.print(error)
                })
                .disposed(by: rx.disposeBag)
        
        }
        else {
            self.showLoginViewController(false)
        }

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
    
    
    @objc
    func observeLoginState() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogin(_:)),
            name: .userDidLogin,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogout(_:)),
            name: .userDidLogout,
            object: nil
        )
        
        if #available(iOS 13.0, *) {
            observeAppleSignInState()
        }
    }
    
    @objc func userDidLogin(_ noti: Notification) {
      dismiss(animated: false, completion: nil)
    }
    
    @objc func userDidLogout(_ noti: Notification) {
       
//        showLoginViewController(true)
    }

    
    @objc
    func handleSignInWithAppleStateChanged(notification: Notification) {
        // Sign the user out, optionally guide them to sign in again
        showLoginViewController()
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

extension UIViewController {
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
