//
//  TopList.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/10.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON

class TopList: NSObject, HandyJSON {
    
    required override init() {
        
    }
    
    var tag: TopTag?
    
    var topList: [User] = []
    
    var list: [User] = []
    
    var userInfo: User?
    
}


struct IntimacyList: HandyJSON {
    
    var topList: [IntimacyTop] = []
    var list: [IntimacyTop] = []
}


struct IntimacyTop: HandyJSON {
    
    var girlInfo: User!
    var userInfo: User!
    var intimacy: Float = 0
    var rankId: Int = 0
    /// 亲密度
    var userIntimacy: Float = 0
}
