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
    
    var callCode: Int = 0
    var msg: String = ""
    
    var isSuccessd: Bool {
        return callCode == 1
    }
    

}
