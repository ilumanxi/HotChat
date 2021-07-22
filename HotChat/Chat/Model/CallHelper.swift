//
//  CallHelper.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import AVFoundation


@objc class CallHelper: NSObject {
    
    
    static let share = CallHelper()
    
    let imAPI = Request<IMAPI>()
    
    func checkCall(_ toUser: User, type: CheckCallType, indicatorDisplay: IndicatorDisplay & UIViewController) -> Bool {
        

        guard let user = LoginManager.shared.user else {
            
            return false
        }
        
        if user.sex == .male {
            if toUser.sex == .male {
                indicatorDisplay.show("对方设置隐私保护不接受\(type.string)")
                return false
            }
            else if toUser.sex == .female && !toUser.girlStatus {
                
                if type == .text && user.userRank < 10 {
                    indicatorDisplay.show("对方设置隐私保护需要富豪等级10级才可以留言")
                    return false
                }
                
                if type == .image && user.vipType == .empty {
                    indicatorDisplay.show("需要VIP才能发送图片哦")
                    return false
                }
                
                if type == .video &&  user.userRank < 10 {
                    indicatorDisplay.show("对方设置隐身保护需要富豪等级10级才可以视频")
                    return false
                }
            }
            else if toUser.girlStatus && type == .image && user.vipType == .empty {
                indicatorDisplay.show("需要VIP才能发送图片哦")
                return false
            }
        }
        
        
        if user.sex == .female && !user.girlStatus {
            
            if toUser.sex == .male && type == .image && user.vipType == .empty {
                indicatorDisplay.show("需要VIP才能发送图片哦")
                return false
            }
            else if toUser.sex == .male && type == .video {
                indicatorDisplay.show("对方设置隐私保护需要认证主播才能视频")
                return false
            }
            else if toUser.sex == .female && !toUser.girlStatus  {
                
                if type == .text  {
                    indicatorDisplay.show("对方设置隐私保护需要认证主播才能留言")
                    return false
                }
                else if type == .image {
                    indicatorDisplay.show("对方设置隐私不接受\(type.string)")
                    return false
                }
                else if type == .audio  {
                    indicatorDisplay.show("对方设置隐私保护需要认证主播才能语聊")
                    return false
                }
                else if type == .video  {
                    indicatorDisplay.show("对方设置隐私保护需要认证主播才能视频")
                    return false
                }
            }
           
            else if toUser.sex == .female && !toUser.girlStatus  {
                indicatorDisplay.show("对方设置隐私保护需要认证主播才能\(type.string)")
                return false
            }
            else if toUser.girlStatus && type == .image {
                indicatorDisplay.show("对方设置隐私不接受图片留言")
                return false
            }
            else if toUser.girlStatus {
                indicatorDisplay.show("对方设置隐私保护需要认证主播才能\(type.string)")
                return false
            }
        }
        
        
        if user.girlStatus {
            
            if  toUser.sex != .male && type == .image {
                indicatorDisplay.show("对方设置隐私不接受图片留言")
                return false
            }
            else if toUser.sex == .female && !toUser.girlStatus {
                indicatorDisplay.show("对方设置隐私不接受\(type.string)")
                return false
            }
            else if toUser.girlStatus  {
                indicatorDisplay.show("对方设置隐私保护需要异性才能\(type.string)")
                return false
            }
            
        }
        
        return true
        
    }
    
    @objc func call(userID: String, callType: CallType, callSubType: CallSubType = .none) {
        
        switch callType {
        case .video:
            handleCallVideo(userID: userID, callSubType: callSubType)
        case .audio:
            handleCallAudio(userID: userID, callSubType: callSubType)
        default:  break
        }
    }

    
    private func handleCallVideo(userID: String, callSubType: CallSubType) {
      
        if checkAuthorization(for: .video) {
            if checkAuthorization(for: .audio) {
                makeCall(userID: userID, callType: .video, callSubType: callSubType)
            }
            else {
               showAudioPermissionnNotification()
            }
        }
        else {
            showVideoPermissionnNotification()
        }
    }
    
    private func checkAuthorization(for mediaType: AVMediaType) -> Bool {
        
        var authorized = false
        let semaphore = DispatchSemaphore(value: 0)
        
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                authorized = granted
                semaphore.signal()
            }
        case .restricted:
            authorized = false
            semaphore.signal()
        case .denied:
            authorized = false
            semaphore.signal()
        case .authorized:
            authorized = true
            semaphore.signal()
        @unknown default:
            authorized = false
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
         
        return authorized
    }
    
    
    private func handleCallAudio(userID: String, callSubType: CallSubType) {
      
        if checkAuthorization(for: .audio) {
            makeCall(userID: userID, callType: .audio, callSubType: callSubType)
        }
        else {
            showAudioPermissionnNotification()
        }
    }

    
    private func makeCall(userID: String, callType: CallType, callSubType: CallSubType) {
        
        let type  = (callType == .video) ? 1 : 2
        
        imAPI.request(.checkUserCall(type: type, toUserId: userID), type: Response<CallStatus>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else {return }
                if response.data!.isSuccessd  && response.data!.callCode == 1{
                    TUICallUtils.setGenerateRoomID( response.data!.roomId)
                    CallManager.shareInstance()?.call(nil, userID: userID, callType: callType, callSubType: callSubType)
                }
                else if response.data!.callCode == 4 {
                      
                    let vc =  TipAlertController(title: "温馨提示", message:  "您的能量不足，请充值", leftButtonTitle: "取消", rightButtonTitle: "立即充值")
                    vc.onRightDidClick.delegate(on: self) { (self, _) in
                        let vc = WalletViewController()
                        self.getShowNavigationController()?.pushViewController(vc, animated: true)
                    }
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                else {
                    UIApplication.shared.keyWindow?.makeToast(response.data?.msg)
                }
            }, onError: {  error in
                UIApplication.shared.keyWindow?.makeToast(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func showAudioPermissionnNotification()  {
        Thread.safeAsync {
            let alert = UIAlertController(title: nil, message: "请在iPhone“设置-隐私-麦克风”选项中，允许贪聊访问你的手机麦克风。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        

    }
    
    private func showVideoPermissionnNotification()  {
        Thread.safeAsync {
            let alert = UIAlertController(title: nil, message: "请在iPhone“设置-隐私-相机”选项中，允许贪聊访问你的相机。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }

    }
    
    private func getShowNavigationController() -> UINavigationController? {
        
        guard let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController, let navController = tabController.selectedViewController as? UINavigationController else {
            return nil
        }
        
        return navController
    }
}
