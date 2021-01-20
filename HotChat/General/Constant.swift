//
//  Constant.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation


class Constant: NSObject {
    
    static var versionString: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
   
    static var hotChatAppAuthURL: URL {
        return URL(string: "\(Constant.hotChatScheme)://authorize/")!
    }
    
    static let hotChatScheme = "tanliao"
}


extension Constant {
    
    struct TPNS {
        
        static var accessID: UInt32 = 1600016588
        static var accessKey = "I72KQO6K5I84" 
    }
    
}


#if DEBUG

/// 测试
extension Constant {

    @objc static var APIHostURL: URL {
        return URL(string: "http://\(Constant.Server.APIHost)")!
    }

    static var H5HostURL: URL {
        return URL(string: "http://\(Constant.Server.H5Host)")!
    }


    struct IM {

        static let appID: UInt32 = 1400457429
        static let businessID: Int32 = 24634
    }


    struct Server {

        static let APIHost = "ceshiapi.yuupni.com/gateway.php"
        static let H5Host = "ceshiadmin.yuupni.com"
        static let salt: String = "AJ265TT96e930d4d0YUddbcbPjc39CFK"
    }
}


#else

/// 正式
extension Constant {

    @objc static var APIHostURL: URL {
        return URL(string: "https://\(Constant.Server.APIHost)")!
    }

    static var H5HostURL: URL {
        return URL(string: "https://\(Constant.Server.H5Host)")!
    }


    struct IM {

        static let appID: UInt32 = 1400424749
        static let businessID: Int32 = 23246
    }

    struct Server {

        static let APIHost = "pic.yuupni.com"
        static let H5Host = "admin.yuupni.com"
        static let salt: String = "AJ265TT96e930d4d0YUddbcbPjc39CFK"
    }

}

#endif

extension Constant {
    
    static var pushChannelId: String? {
        
        return XGPushTokenManager.default().xgTokenString
    }
}
