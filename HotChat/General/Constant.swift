//
//  Constant.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import SYBPush


struct Constant {
    
    static var versionString: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
   
    static var hotChatAppAuthURL: URL {
        return URL(string: "\(Constant.hotChatScheme)://authorize/")!
    }
    
    static var APIHostURL: URL {
        return URL(string: "http://\(APIHost)")!
    }
    
}


extension Constant {
    static let APIHost = "192.168.0.251/gateway.php"
    static let salt: String = "AJ265TT96e930d4d0YUddbcbPjc39CFK"
    static let hotChatScheme = "hotchatauth2"
}


extension Constant {
    
    static var pushChannelId: String? {
        
        return BPush.getChannelId()
    }
}
