//
//  ChatGreet.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON

enum ChatGreetStatus: Int, HandyJSONEnum {
    /// 未审核/审核中
    case empty = 0
    
    /// 审核通过
    case ok = 1
    
//    /// 审核中
//    case validating = 2

    /// 审核失败
    case failed = 2
}



struct ChatGreet: HandyJSON {
    var id: String = ""
    var content: String = ""
    var status: ChatGreetStatus = .empty
}
