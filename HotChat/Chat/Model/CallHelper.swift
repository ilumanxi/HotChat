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
    
    func call(userID: String, callType: CallType) {
        
        switch callType {
        case .video:
            handleCallVideo(userID: userID)
        case .audio:
            handleCallAudio(userID: userID)
        default:  break
        }
    }

    
    private func handleCallVideo(userID: String) {
      
        if checkAuthorization(for: .video) {
            if checkAuthorization(for: .audio) {
                makeCall(userID: userID, callType: .video)
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
    
    
    private func handleCallAudio(userID: String) {
      
        if checkAuthorization(for: .audio) {
            makeCall(userID: userID, callType: .audio)
        }
        else {
            showAudioPermissionnNotification()
        }
    }

    
    private func makeCall(userID: String, callType: CallType) {
        
        let type  = (callType == .video) ? 1 : 2
        
        imAPI.request(.checkUserCall(type: type, toUserId: userID), type: Response<CallStatus>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else {return }
                if response.data!.isSuccessd  && response.data!.callCode == 1{
                    CallManager.shareInstance()?.call(nil, userID: userID, callType: callType)
                }
                else if response.data!.callCode == 4 {
                    let alert = UIAlertController(title: nil, message: "您的能量不足、请充值！", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "立即充值", style: .default, handler: { _ in
                        let vc = WalletViewController()
                        self.getShowNavigationController()?.pushViewController(vc, animated: true)
                        
                    }))
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
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
