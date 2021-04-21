//
//  CheckIn.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/7.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON


struct CheckIn: HandyJSON {

    /// 0未签到1已签到
    var status: Bool = false
    var days: Int = 0
    var energy: Int = 0
    var title: String = ""
}


struct CheckInResult: HandyJSON, State {

    var day: Int = 0
    var energy: Int = 0
    var content: String = ""
    var isDouble: Bool = false
    /// １０１０：签到成功　1008未签到 1009已签到

    var resultCode: Int = 0
    var resultMsg: String = ""
    
    var isSuccessd: Bool {
        return resultCode == 1010 ||   resultCode == 1008
    }
    
    var error: Error? {
        
        if isSuccessd {
            return nil
        }
        
        return NSError(domain: "", code: resultCode, userInfo: [NSLocalizedDescriptionKey: resultMsg])
    }
}
