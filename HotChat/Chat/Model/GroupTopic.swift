//
//  GroupTopic.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/18.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON
enum GroupTopicStatus: Int, HandyJSONEnum {
    /// 正常
    case normal
    /// 拥挤
    case crowd
    /// 爆满
    case full
}




extension GroupTopicStatus {
    var isHidden: Bool {
        return self == .normal
    }
}


class GroupTopic: NSObject, HandyJSON {
    
    required override init() {
        
    }
    
    var groupId: String = ""
    var name: String = ""
    var coverPic: String = ""
    var status: GroupTopicStatus = .normal
}
