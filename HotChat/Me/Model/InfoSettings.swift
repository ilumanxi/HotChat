//
//  InfoSettings.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON

struct InfoSettings: HandyJSON {
    
    /// 开启视频聊天 1开启 0关闭
    var isLive = true
    
    /// 语音聊天 1开启 0关闭
    var isVoice = true
    
    /// 打扰 1开启 0关闭
    var isDisturb = false
    
    /// 隐藏定位 0关闭 1开启
    var isLocation = false
    
}
