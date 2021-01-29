//
//  NavigationMap.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

import SafariServices
import URLNavigator

extension Navigator {
    
    static let share = Navigator()
}



func HotChatURLString(path: String) -> String {
    return "\(Constant.hotChatScheme)://\(path)"
}


enum NavigationMap {
  static func initialize(navigator: NavigatorType) {
    
   
    navigator.register(HotChatURLString(path: "jump/recharge")) { url, values, context in
        
      return WalletViewController()
    }
    
    navigator.register(HotChatURLString(path: "jump/bindingPhone")) { url, values, context in
      return PhoneBindingController()
    }
    
    
    navigator.register(HotChatURLString(path: "jump/editProfile")) { url, values, context in
        return  UserInfoEditingViewController.loadFromStoryboard()
    }
    
    
    navigator.register(HotChatURLString(path: "jump/editLabel")) { url, values, context in
        let vc = UserInfoLikeObjectViewController.loadFromStoryboard()
        vc.onUpdated.delegate(on: vc) {  (controller, _) in
            controller.navigationController?.popViewController(animated: true)
        }
      vc.sex = LoginManager.shared.user!.sex
      return  vc
    }
    
    
    navigator.register(HotChatURLString(path: "jump/chatmatch")) { url, values, context in
        return  PairsViewController.loadFromStoryboard()
    }

    navigator.register(HotChatURLString(path: "jump/editIntroduction")) { url, values, context in
        return  UserInfoInputTextViewController.loadFromStoryboard()
    }
    
    navigator.register(HotChatURLString(path: "jump/nameAuthentication")) { url, values, context in
        
        if LoginManager.shared.user?.sex == .female  {
            return AnchorAuthenticationViewController()
        }
        else {
            return RealNameAuthenticationViewController.loadFromStoryboard()
        }
    }
     
    navigator.handle(HotChatURLString(path: "jump/home"), self.home(navigator: navigator))
    
    navigator.register("http://<path:_>", self.webViewControllerFactory)
    navigator.register("https://<path:_>", self.webViewControllerFactory)

    navigator.handle("navigator://alert", self.alert(navigator: navigator))
    navigator.handle("navigator://<path:_>") { (url, values, context) -> Bool in
      // No navigator match, do analytics or fallback function here
      print("[Navigator] NavigationMap.\(#function):\(#line) - global fallback function is called")
      return true
    }
  }

  private static func webViewControllerFactory(
    url: URLConvertible,
    values: [String: Any],
    context: Any?
  ) -> UIViewController? {
    
    guard let url = url.urlValue else { return nil }
    
    return WebViewController(url: url)
  }
    
  //  tanliao://jump/home?index=1
  private static func home(navigator: NavigatorType) -> URLOpenHandlerFactory {
    return { url, values, context in
        guard let indexStringValue = url.queryParameters["index"], let index = Int(indexStringValue) else { return false }
 
        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController else { return false }
        
        guard let navigationController = tabBarController.selectedViewController as? UINavigationController else { return false }
        
        navigationController.popToRootViewController(animated: false)
        tabBarController.selectedIndex = index
        
        return true
    }
  }

  private static func alert(navigator: NavigatorType) -> URLOpenHandlerFactory {
    return { url, values, context in
      guard let title = url.queryParameters["title"] else { return false }
      let message = url.queryParameters["message"]
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      navigator.present(alertController)
      return true
    }
  }
}
