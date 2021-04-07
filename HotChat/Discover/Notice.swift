//
//  Notification.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON

class Notice: NSObject, HandyJSON {

    
    /// Type：１评论　２点赞　３礼物
    var eventType: Int = 0
    
    var dataType: Int = 0

    var data: Dynamic?
    
    var content: String = ""
    
    var isRead: Bool = false
    
    var timeFormat: String = ""
    
    var userInfo: User?
    
    
    required override init() {
        
    }
}
