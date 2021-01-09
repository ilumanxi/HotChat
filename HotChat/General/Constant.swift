//
//  Constant.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import SYBPush_normal


class Constant: NSObject {
    
    static var versionString: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
   
    static var hotChatAppAuthURL: URL {
        return URL(string: "\(Constant.hotChatScheme)://authorize/")!
    }
    
    @objc static var APIHostURL: URL {
        return URL(string: "http://\(APIHost)")!
    }
    
    static var H5HostURL: URL {
        return URL(string: "http://\(H5Host)")!
    }
    
}


extension Constant {
    
    /// 正式

    static let APIHost = "pic.yuupni.com"

    static let H5Host = "admin.yuupni.com"

    static let IMAppID: UInt32 = 1400424749
    
    /// 测试
    
//    static let APIHost = "ceshiapi.yuupni.com/gateway.php"
//
//    static let H5Host = "ceshiadmin.yuupni.com"
//
//    static let IMAppID: UInt32 = 1400457429
    
    static let ANPSBusinessID = 23246

    static let salt: String = "AJ265TT96e930d4d0YUddbcbPjc39CFK"
    static let hotChatScheme = "hotchatauth2"
}


extension Constant {
    
    static var pushChannelId: String? {
        
        return BPush.getChannelId()
    }
}
