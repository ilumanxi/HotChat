//
//  CallStatus.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON

class CallStatus: NSObject, HandyJSON {
    
    required override init() {
        super.init()
    }
    
    //callCode -1快没钱1正常 2你的余额不满三分钟，请先充值 3对方开启了视频防骚扰4能量不足 5同性不能聊天
    var callCode: Int = 0
    var msg: String = ""
    
    var isSuccessd: Bool {
        return callCode == 1
    }
    

}
