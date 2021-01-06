//
//  AppAudit.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/5.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON


@objc class AppAudit: NSObject, HandyJSON { // false 显示。true 不显示
    
    required override init() {
        
    }
    
    /// 和他打招呼按钮
    @objc var greetStatus = false
    
    /// 按钮上的能量价格
    @objc var energyStatus = false
    
    /// 按钮上的能量价格
    @objc var onekeyStatus = false
    
    /// IM中拨打按钮
    @objc var imcallStatus = false
    
    /// 机器人打招呼
    @objc var robotGreetStatus = false
    
    /// 奖励任务
    @objc var taskStatus = false

    ///  等级
    @objc var gradeStatus = false

    /// 我的邀请
    @objc var inviteStatus = false
    
    /// 签到弹窗
    @objc var signinStatus = false
    
    @objc static var  share = AppAudit() {
        didSet {
            NotificationCenter.default.post(name: .appApprovedDidChange, object: nil)
        }
    }
}