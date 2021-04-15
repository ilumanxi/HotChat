//
//  ChargeConfig.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/14.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON

class ChargeConfig: NSObject, HandyJSON {

    var voiceList: [ChargeConfigItem] = []
    
    var videoList: [ChargeConfigItem] = []
    
    required override init() {
        
    }
}


class ChargeConfigItem: NSObject, HandyJSON {
    
    var chargeId: String = ""
    var charge: Int = 0
    var isCheck: Bool = false
    var level: Int = 0
    
    required override init() {
        
    }
    
}
