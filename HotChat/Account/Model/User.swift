//
//  User.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import HandyJSON

struct User: HandyJSON {
    
    enum Sex: Int {
        case male = 1
        case female = 2
    }
    
    var userId: Int = 0
    var token: String = ""
    var status: Int = 0
    var isInit: Int = 0
}
