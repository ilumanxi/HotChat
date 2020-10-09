//
//  HotChatResponse.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import HandyJSON

struct ResponseEmptyType: HandyJSON {
    
}

typealias ResponseEmpty = Response<ResponseEmptyType>

struct Response<T: HandyJSON>: HandyJSON {

    var code: Int!
    var msg: String = ""
    
    var data: T?
    
    var isSuccessd: Bool {
         return code == 1
    }
}
