//
//  WeChat.swift
//  Share
//
//  Created by 风起兮 on 2019/5/29.
//  Copyright © 2019 风起兮. All rights reserved.
//  https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=1417694084&token=&lang=zh_CN
//  https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419319164&lang=zh_CN
//

import UIKit


class WeChat: NSObject {
    
    struct Config {
        static let appId = "wxe17e385df8f45639"
        static let appSecret = "9ad8fe522377fb1f9130816f87400391"
        static let scope = "snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact" // @"post_timeline,sns"
        static let state = "HotChat"
        static let universalLink = "https://www.zhouwu5.com/"
    }
    
    
    enum Scene: Int {
        case session = 0
        case timeline = 1
    }
    
    struct Key {
       static let errcode: String = "errcode"
       static let errmsg: String = "errmsg"
    }
    
    typealias CompletionHandler = (Swift.Result<String, AuthorizationError>) -> Void
    
    typealias ShareCompletionHandler = (AuthorizationError?) -> Void
    
    private var completionHandler: CompletionHandler?
    
    private var shareCompletionHandler: ShareCompletionHandler?
    
    static let `default`: WeChat = WeChat()
    
    private override init() {
        super.init()
    }
    
    func application(_ app: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        
//        WXApi.startLog(by: .detail) { log in
//            debugPrint("WeChatSDK.startLog: \(log)")
//        }
        WXApi.registerApp(Config.appId,universalLink: Config.universalLink)
        
//        WXApi.checkUniversalLinkReady { (step, result) in
//            debugPrint("WeChatSDK.CheckUniversalLinkReady:  \(result.success), \(result.errorInfo), \(result.suggestion)")
//        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        

        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }
    
    func login(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
        
        let req = SendAuthReq()
        req.scope = Config.scope
        req.state = Config.state
        req.openID = Config.appSecret
        let vc = UIApplication.shared.keyWindow!.rootViewController!
        
        WXApi.sendAuthReq(req, viewController: vc, delegate: self) { result in
            if !result {
                self.completionHandler?(.failure(.notInstalled))
                self.completionHandler = nil
            }
        }
    }
    
    func share(scene: WeChat.Scene, webpageUrl: URL, title: String, description: String, thumbImage: URL?, completionHandler: @escaping ShareCompletionHandler) {
        
        self.shareCompletionHandler = completionHandler
        
        let webpage = WXWebpageObject()
        webpage.webpageUrl = webpageUrl.absoluteString
        
        let message = WXMediaMessage()
        message.title = title
        message.description = description
        
        if let thumbImage = thumbImage, let data = try? Data(contentsOf: thumbImage), let image = UIImage(data: data) {
            message.thumbData =  image.compress(toByte: 32 * 1024)
        }
        message.mediaObject = webpage
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        if !WXApi.isWXAppInstalled() {
            self.shareCompletionHandler?(.notInstalled)
            self.shareCompletionHandler = nil
        }
        else {
            
        }
        WXApi.send(req) { result in
            if !result {
                self.shareCompletionHandler?(.network)
                self.shareCompletionHandler = nil
            }
        }
    }

    
}

extension WeChat {
    
    /**
     通过code获取access_token的接口。
     http请求方式: GET
     https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
     appid          是    应用唯一标识，在微信开放平台提交应用审核通过后获得
     secret         是    应用密钥AppSecret，在微信开放平台提交应用审核通过后获得
     code           是    填写第一步获取的code参数
     grant_type     是    填authorization_code
     
     result
     access_token    接口调用凭证
     expires_in      access_token接口调用凭证超时时间，单位（秒）
     refresh_token   用户刷新access_token
     openid          授权用户唯一标识
     scope           用户授权的作用域，使用逗号（,）分隔
     unionid         当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段
     error
     {
     "errcode":40029,"errmsg":"invalid code"
     }
     */
    
    class func accessToken(appid: String, secret: String, code: String, grantType: String = "authorization_code", complete: @escaping (_ result: Swift.Result<[String: Any], NSError>) -> Void) {
        
        
        var urlComponents = URLComponents(string: "https://api.weixin.qq.com/sns/oauth2/access_token")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "secret", value: secret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: grantType)
        ]
        
        URLSession.shared
            .dataTask(with: urlComponents.url!) { (data, response, error) in
                
                if let error = error {
                    complete(.failure(error as NSError))
                }
                else if let data = data {
                    let json  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                    
                    if json.keys.contains(Key.errcode){
                        let failure =  NSError(domain: json[Key.errmsg] as! String, code: json[Key.errcode] as! Int, userInfo: nil)
                        complete(.failure(failure))
                    }
                    else {
                        complete(.success(json))
                    }
                }
                
            }
            .resume()
    }
    
    /**
     获取用户个人信息（UnionID机制）
     http请求方式: GET
     https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
     access_token    是    调用凭证
     openid          是    普通用户的标识，对当前开发者帐号唯一
     lang            否    国家地区语言版本，zh_CN 简体，zh_TW 繁体，en 英语，默认为zh-CN
     result
     openid         普通用户的标识，对当前开发者帐号唯一
     nickname       普通用户昵称
     sex            普通用户性别，1为男性，2为女性
     province       普通用户个人资料填写的省份
     city           普通用户个人资料填写的城市
     country        国家，如中国为CN
     headimgurl     用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空
     privilege      用户特权信息，json数组，如微信沃卡用户为（chinaunicom）
     unionid        用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。
     error
     {
     "errcode":40003,"errmsg":"invalid openid"
     }
     */
    class func userInfo(accessToken: String, openId: String, lang: String? = nil, complete: @escaping (_ result: Swift.Result<[String: Any], NSError>) -> Void) {
        
        var urlComponents = URLComponents(string: "https://api.weixin.qq.com/sns/userinfo")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "openid", value: openId),
            URLQueryItem(name: "lang", value: lang ?? "")
        ]
        
        URLSession.shared
            .dataTask(with: urlComponents.url!) { (data, response, error) in
                
                if let error = error {
                    complete(.failure(error as NSError))
                }
                else if let data = data {
                    let json  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                    
                    if json.keys.contains(Key.errcode){
                        let failure =  NSError(domain: json[Key.errmsg] as! String, code: json[Key.errcode] as! Int, userInfo: nil)
                        complete(.failure(failure))
                    }
                    else {
                        complete(.success(json))
                    }
                }
            }
            .resume()
    }
}


extension WeChat : WXApiDelegate {
    
    func onReq(_ req: BaseReq) {
        debugPrint("\(#function) req")
    }
    
    
    func onResp(_ resp: BaseResp) {
        
        if let auth = resp as? SendAuthResp {
//            login(auth: auth)
            self.completionHandler?(.success(auth.code!))
        }
        else if let auth = resp as? SendMessageToWXResp {
            share(auth: auth)
        }
    }
    
    private func login(auth: SendAuthResp) {
        if auth.errCode == WXSuccess.rawValue {
            WeChat.accessToken(appid: Config.appId, secret: Config.appSecret, code: auth.code!) { result in
                switch result {
                case .success(let json):
                    let accessToken = json["access_token"] as! String
                    let openId = json["openid"] as! String
                    self.userInfo(accessToken: accessToken, openId: openId)
                case .failure(let error):
                    self.completionHandler?(.failure(.failed(reason: error)))
                    self.completionHandler = nil
                }
            }
        }
        else if auth.errCode == WXErrCodeUserCancel.rawValue {
            self.completionHandler?(.failure(.cancel))
            self.completionHandler = nil
        }
        else if auth.errCode == WXErrCodeAuthDeny.rawValue {
            self.completionHandler?(.failure(.authorize))
            self.completionHandler = nil
        }
    }
    
    private func share(auth: SendMessageToWXResp) {
        if auth.errCode == WXSuccess.rawValue {
            self.shareCompletionHandler?(nil)
            self.shareCompletionHandler = nil
        }
        else {
            self.shareCompletionHandler?(nil)
            self.shareCompletionHandler = nil
        }
    }
    
    private func userInfo(accessToken: String, openId: String) {
        WeChat.userInfo(accessToken: accessToken, openId: openId) { result in
            switch result {
            case .success(let json):
                let accessToken = accessToken
                let userID = json["unionid"] as? String ?? ""
                let displayName = json["nickname"] as? String ?? ""
                let headimgurl = json["headimgurl"] as? String ?? ""
                let pictureURL = URL(string: headimgurl)
                let sex = json["sex"] as? Int ?? 0
                let gender =  AuthorizationUser.Gender(rawValue: sex)!
                let user = AuthorizationUser(nickname: displayName, gender: gender, birthday: nil, userID: userID, accessToken: accessToken, pictureURL: pictureURL)
//                self.completionHandler?(.success(user))
                self.completionHandler = nil
            case .failure(let error):
                self.completionHandler?(.failure(.failed(reason: error)))
                self.completionHandler = nil
            }
        
        }
    }
}


extension UIImage {
    
    func compress(toByte maxLength: Int) -> Data {
        
        var compression: CGFloat = 1.0
        var data  = self.jpegData(compressionQuality: compression)!
        if data.count <=  maxLength{
            return data
        }
        
        var max: CGFloat = 1.0
        var min: CGFloat = 0
        
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
            if data.count < Int(CGFloat(maxLength) * 0.9) {
                min = compression
            }
            else if (data.count > maxLength) {
                max = compression;
            } else {
                break
            }
        }
        
        var resultImage = UIImage(data: data)!
        
        if data.count < maxLength {
            return data
        }
        
        var lastDataLength = 0
        
        while data.count > maxLength && data.count != lastDataLength {
            autoreleasepool {
                lastDataLength = data.count
            
                let ratio =  Float(CFloat(maxLength) / CFloat(data.count))
                let size = CGSize(width: resultImage.size.width * CGFloat(sqrtf(ratio)), height: resultImage.size.height * CGFloat(sqrtf(ratio)))
                UIGraphicsBeginImageContext(size)
                resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                resultImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                data = resultImage.jpegData(compressionQuality: compression)!
                
            }
        }
        
        return data
    }
}
