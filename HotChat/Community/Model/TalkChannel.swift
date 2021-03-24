//
//  TalkChannel.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/24.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import HandyJSON


enum TalkChannelType: Int, HandyJSONEnum {
    case unknown = 0
    case user = 1
    case banner = 2
}

class TalkChannel: NSObject, HandyJSON {
    
    required override init() {
        
    }
    
    var type: TalkChannelType = .unknown
    
    var bannerList: [Banner] = []
    
    var userInfo: User?
}
