//
//  Interflow.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON

struct Interflow: HandyJSON {
    
    var timeFormat: String = ""
    var userIntimacy: Float = 0
    
    var userInfo: User!
}


struct IntimacyInfo: HandyJSON {
    
    var intimacy: Float = 0
    var name: String = ""
    var voice: Bool = false
    var video: Bool = false
    var explain: String = ""
    var status: IntimacyInfoStatus = .normal
    var icon: String = ""
}


enum IntimacyInfoStatus: Int, HandyJSONEnum {
    /// 未解封
    case normal = 2
    /// 已经解封
    case deblocking = 0
    /// 当前解封
    case currentDeblocking = 1
}
