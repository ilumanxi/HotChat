//
//  IM.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
//import TXIMSDK_TUIKit_iOS

class IM {
    
    static let appID: UInt32 = 1400424749
    
    
    static func setSelfInfo(_ user: User) {
        
        let info = V2TIMUserFullInfo()
        info.nickName = user.nick
        info.faceURL =  user.headPic
        info.selfSignature = user.introduce
        
        V2TIMManager.sharedInstance()?.setSelfInfo(
            info,
            succ: {
                Log.print("setSelfInfo: \(user)")
            },
            fail: { code, desc in
                Log.print("\(code) \(desc ?? "")")
            }
        )
    }
    
}
