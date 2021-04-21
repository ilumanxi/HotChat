//
//  AppAudit.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/5.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON


@objc class AppAudit: NSObject, HandyJSON {
    
    /// 是否禁用。false。true
    
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
    
    /// 一键搭讪
    @objc var accostStatus = false
    
    /// 一键登录
    @objc var oneKeyLoginStatus = false
    
    @objc static var  share = AppAudit() {
        didSet {
            NotificationCenter.default.post(name: .appApprovedDidChange, object: nil)
        }
    }
}
