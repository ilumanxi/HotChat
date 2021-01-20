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

enum NavigationMap {
  static func initialize(navigator: NavigatorType) {
    
    
    navigator.register("\(Constant.hotChatScheme)://jump/recharge") { url, values, context in
        
      return WalletViewController()
    }
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
