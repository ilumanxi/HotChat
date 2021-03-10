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
