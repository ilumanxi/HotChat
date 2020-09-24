//
//  ShareAuthorization.swift
//  ShareAuthorization
//
//  Created by 风起兮 on 2019/5/29.
//  Copyright © 2019 风起兮. All rights reserved.
//

import UIKit

class PlatformAuthorization: NSObject {
    
    public struct InfoKey: Hashable, Equatable, RawRepresentable {

        public var rawValue: String
        
        public typealias RawValue = String

        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let webpageUrl: InfoKey = InfoKey(rawValue: "webpageUrl")! // Web site URL
        
        public static let images: InfoKey = InfoKey(rawValue: "images")! // [URL]
        
        public static let title: InfoKey = InfoKey(rawValue: "title")! // String
        
        public static let description: InfoKey = InfoKey(rawValue: "description")! // String
        
        public static let type: InfoKey = InfoKey(rawValue: "type")! // String
        
        public static let previewImageUrl: InfoKey = InfoKey(rawValue: "previewImageUrl")! // URL
        
    }
    
    
   typealias CompletionHandler = (AppType, Swift.Result<String, AuthorizationError>) -> Void

   typealias ShareCompletionHandler = (PlatformType, AuthorizationError?) -> Void
    
   class func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        WeChat.default.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    

    
    class func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if WeChat.default.application(app, open: url, options: options){
            return true
        }
 
        return false
    }
    
    class func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if WeChat.default.application(application, continue: userActivity, restorationHandler: restorationHandler) {
            return true
        }

        return false
    }
    
    class func login(_ app: AppType, completionHandler: @escaping CompletionHandler) {
        
        switch app {
        case .wechat:
            WeChat.default.login { result in
                completionHandler(.wechat, result)
            }
        }
    }
    
    
    class func share(_ platformType: PlatformType, info: [PlatformAuthorization.InfoKey : Any], completionHandler: @escaping ShareCompletionHandler) {
        
        switch platformType {
        case .wechatSession:
            WeChat.default.share(scene: .session, info: info) { error in
                completionHandler(.wechatSession, error)
            }
        case .wechatTimeline:
            WeChat.default.share(scene: .timeline, info: info) { error in
                completionHandler(.wechatSession, error)
            }
        }
    }
    
}

extension WeChat {
    
    
    func share(scene: WeChat.Scene, info: [PlatformAuthorization.InfoKey : Any], completionHandler: @escaping WeChat.ShareCompletionHandler) {
        let webpageUrl = info[.webpageUrl] as! URL
        let queryItem = URLQueryItem(name: "channel", value: "wechat")
        let urlComponents = NSURLComponents(url: webpageUrl, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems?.append(queryItem)
        
        guard let shareUrl = urlComponents?.url else{
            return
        }
        let title = info[.title] as! String
        let description = info[.description] as! String
        let thumbImage = info[.previewImageUrl] as? URL
        
        WeChat.default.share(scene: scene, webpageUrl: shareUrl, title: title, description: description, thumbImage:thumbImage, completionHandler: completionHandler)
    }
}
