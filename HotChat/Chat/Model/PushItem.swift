//
//  PushItem.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON

class PushItem: NSObject, HandyJSON {
    
    var isConnect: Bool = false
    var timeFormat: String = ""
    var userInfo: User!
    required override init() {
        
    }

}
