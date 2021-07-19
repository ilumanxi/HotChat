//
//  IMAPI.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Moya
import Kingfisher
import RxSwift
import RxCocoa

extension UIImageView {
    @objc func setKF(_ url: URL?) {
        kf.indicatorType = .activity
        kf.setImage(with: url)
    }
}

enum IMAPI {
    case call(type: Int, toUserId: String)
    case checkUserCall(type: Int, toUserId: String)
    case getCallTime(roomId: Int)
    case imChatStatus(toUserId: String)
    case callend(userId: String, roomId: Int)
}

extension IMAPI: TargetType {

    var path: String {
        switch self {
        case .call:
            return "Im/call"
        case .checkUserCall:
            return "Im/checkUserCall"
        case .getCallTime:
            return "Im/getCallTime"
        case .imChatStatus:
            return "Im/imChatStatus"
        case .callend(let userId, _):
            return "v1/imcall/callend/\(userId)"
        }
    }
    
    var task: Task {
        
        let parameters: [String : Any]
        
        switch self {
        case .call(let type, let toUserId):
            parameters = [
                "type" : type,
                "toUserId" : toUserId
            ]
        case .checkUserCall(let type, let toUserId):
            parameters = [
                "type" : type,
                "toUserId" : toUserId
            ]
        case .getCallTime(let roomId):
            parameters = [
                "roomId" : roomId
            ]
        case .imChatStatus(let toUserId):
            parameters = [
                "toUserId" : toUserId
            ]
        case .callend(_ , let roomId):
            parameters = [
                "roomId" : roomId
            ]
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
}


@objc class IMHelper: NSObject {
    

    static let API  = Request<IMAPI>()
    
    static let userAPI  = Request<UserAPI>()
    
    static let disposeObject = DisposeBag()
    
    @objc class func image(color: UIColor, size: CGSize) -> UIImage {
        return  UIImage(color: color, size: size)
    }
    
    @objc class func  getCallTime(_ roomId: Int, success: @escaping ([String : Any]) -> Void, failed: @escaping (NSError) -> Void) {
        
        API.request(.getCallTime(roomId: roomId), type: Response<[String : Any]>.self).verifyResponse()
            .subscribe(onSuccess: { response in
                success(response.data ?? [:])
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: disposeObject)
    }
    
    @objc class func  getUser(_ userID: String, success: @escaping (User) -> Void, failed: @escaping (NSError) -> Void) {
        
        userAPI.request(.userinfo(userId: userID), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { response in
                success(response.data!)
            }, onError: { error in
                failed(error as NSError)
            })
            .disposed(by: disposeObject)
    }
    
    @objc class func  callend(_ userID: String, roomId: Int) {
        userAPI.request(.userinfo(userId: userID), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: disposeObject)
    }
}





extension Notification.Name {
    
    /// 跑马灯礼物
    static let marqueeGiftDidSend = NSNotification.Name("com.friday.Chat.marqueeGiftDidSend")
    
    /// 跑马灯头条
    static let marqueeHeadlineDidSend = NSNotification.Name("com.friday.Chat.marqueeHeadlineDidSend")
    
    /// 相关通知
    static let dynamicDidForYou = NSNotification.Name("com.friday.Chat.dynamicDidForYou")
    
    /// 礼物赠送
    static let giftDidPresent = NSNotification.Name("com.friday.Chat.giftDidPresent")
    
    /// 上线通知
    static let onlineDidStatus = NSNotification.Name("com.friday.Chat.onlineDidStatus")
    
    /// 亲密度变化
    static let intimacyDidChange = NSNotification.Name("com.friday.Chat.intimacyDidChange")
    
    /// 聊天违规
    static let chatViolation = NSNotification.Name("com.friday.Chat.chatViolation")
    
    /// 聊天违规
    static let otherChatViolation = NSNotification.Name("com.friday.Chat.otherChatViolation")
    
    
    
}


/// 指令通知
extension IMDataType {
    
    var notificationName: Notification.Name? {
        switch self {
        case IMDataTypeMarqueeGift:
            return .marqueeGiftDidSend
        case IMDataTypeMarqueeHeadline:
            return .marqueeHeadlineDidSend
        case IMDataTypeDynamic:
            return .dynamicDidForYou
        case IMDataTypePresent:
            return .giftDidPresent
        case IMDataTypeOnline:
            return .onlineDidStatus
        case IMDataTypeIntimacy:
            return .intimacyDidChange
        case IMDataTypeChatViolation:
            return .chatViolation
        case IMDataTypeOtherChatViolation:
            return .otherChatViolation
        default:
            return nil
        }
    }
    
}
