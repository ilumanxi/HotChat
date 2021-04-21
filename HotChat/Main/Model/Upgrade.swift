//
//  Upgrade.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/18.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON


enum UpgradeType: Int, HandyJSONEnum {
    
    case optional = 1
    case forced = 2
}

extension UpgradeType {
    
    var isHidden: Bool {
        return self == .forced
    }
}

struct Upgrade: State, HandyJSON {

    var type: UpgradeType = .optional
    var content: String = ""
    var downloadUrl: String = ""
    var versionName: String = ""
    var fileSize: String = ""
    /// 100无更新内容 101有更新内容
    var resultCode: Int = 0
    var resultMsg: Int = 101

    var isSuccessd: Bool {
        return resultCode == 101
    }
    
    var error: Error? {
        if isSuccessd {
            return nil
        }
        return NSError(domain: "HotChatError", code: resultCode, userInfo: [NSLocalizedDescriptionKey: "无更新内容"])
    }
}
