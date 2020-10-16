//
//  CallManager.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

/*
enum CallType: Int {
    case unknown
    case audio
    case video
}

enum CallAction: Int {
    ///  系统错误
    case error = -1
    ///  未知流程
    case unknown
    ///  邀请方发起请求
    case call
    ///  邀请方取消请求（只有在被邀请方还没处理的时候才能取消）
    case cancel
    ///  被邀请方拒绝邀请
    case reject
    ///  被邀请方超时未响应
    case timeout
    ///  通话中断
    case end
    ///  被邀请方正忙
    case linebusy
    ///  被邀请方接受邀请
    case accept
}
*/

class CallManager: NSObject {
    
    
    static let share = CallManager()
    
    private(set) var userID: String!
    private(set) var type: CallType!
    
    private(set) var callContrller: UIViewController?
    
    private override init() {
    }
    
    /// 初始化通话模块，TUIKit 初始化的时候调用
    func initCall() {
        TUICall.shareInstance()?.delegate = self
    }
    
    /// 反初始化通话模块
    func unInitCall() {
        TUICall.shareInstance()?.delegate = nil
    }
    
    func call(userID: String, type: CallType) {
        self.userID = userID
        self.type = type

        
    }
    
    fileprivate func callVideo(_ userID: String) {
        TUICallUtils.getCallUserModel(userID) { [weak self] user in
            self?.showCallControler(sponsor: nil, invitedList: [user])
        }
    }
    
    fileprivate func showCallControler(sponsor: CallUserModel?, invitedList: [CallUserModel]) {
        
        switch type {
        case .audio:
            break
        case .video:
            let videoControler = VideoCallViewController(sponsor: nil, invited: invitedList.first!) { [weak self] in
                self?.callContrller = nil
            }
            videoControler.modalPresentationStyle = .fullScreen
            
            UIWindow.topMost?.present(videoControler, animated: true, completion: nil)
            
            let userIds = invitedList.compactMap{ $0.userId }
            TUICall.shareInstance()?.call(userIds, groupID: nil, type: .video)
            
            self.callContrller = videoControler
        default: break
        }
    }
    
    fileprivate func callAudio(_ userID: String) {
            
    }
    

}



extension CallManager: TUICallDelegate {
    
    func onError(_ code: Int32, msg: String!) {
        Log.print("📳 onError: code:\(code) msg:\(msg!)")
    }
    
    func onInvited(_ sponsor: String!, userIds: [Any]!, isFromGroup: Bool, callType: CallType) {
        Log.print("📳 onError: sponsor:\(String(describing: sponsor)) userIds:\(userIds!)")
        self.type = callType
        let userIdList = ([sponsor!] + userIds).compactMap{ $0 as? String }
        
        V2TIMManager.sharedInstance()?.getUsersInfo(
            userIdList,
            succ: { infoList in

                guard let infoList = infoList else { return }
                
                let users = infoList
                    .compactMap{ info -> CallUserModel in
                        let model = CallUserModel()
                        model.name = info.nickName
                        model.avatar = info.faceURL
                        model.userId = info.userID
                        if let videoControler = self.callContrller as? VideoCallViewController,
                           let old = videoControler.getUser(model.userId) {
                            model.isVideoAvaliable = old.isVideoAvaliable
                        }
                        return model
                    }
               
                let sponsorModel =  users.first{ $0.userId == sponsor }
                let inviteeList = users.drop{ $0.userId == sponsor }.compactMap {$0}
                
                self.showCallControler(sponsor: sponsorModel, invitedList: inviteeList)
                
            
            }, fail: { _, _ in
                
            }
        )
        
    }
    
    
    func onGroupCallInviteeListUpdate(_ userIds: [Any]!) {
        Log.print("📳 onGroupCallInviteeListUpdate userIds:\(userIds!)")
    }
    
    func onUserEnter(_ uid: String!) {
        Log.print("📳 onUserEnter uid:\(uid!)")
        TUICallUtils.getCallUserModel(uid) { model in
            model.isEnter = true
            if let videoController = self.callContrller as? VideoCallViewController,
               let oldModel = videoController.getUser(model.userId) {
                model.isVideoAvaliable = oldModel.isVideoAvaliable
                videoController.enter(model)
            }
        }
    }
}
