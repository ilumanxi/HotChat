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


struct ChatGreetResult: HandyJSON {

    /// 1011 已经打招呼过了 1012 可以打招呼
    var resultCode: Int = 0
    var resultMsg: String = ""
    var endTime: TimeInterval = 0
    
    
    var isSuccessd: Bool {
        return resultCode == 1012
    }
    
    var error: Error? {
        if isSuccessd {
            return nil
        }
        
        return NSError(domain: "", code: resultCode, userInfo: [NSLocalizedDescriptionKey : resultMsg])
    }
    
}
