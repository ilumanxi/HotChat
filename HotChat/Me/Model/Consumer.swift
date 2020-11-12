//
//  Consumer.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HandyJSON


@objc enum ConsumerType: Int, HandyJSONEnum {
    /// 支出
    case expense = 1
    /// 收入
    case earning = 2
}

class Consumer: NSObject, HandyJSON {
    
    var title: String = ""
    var time: String = ""
    var energy: String = ""
    
    /// Type： 1减少 2添加2
    var type: ConsumerType!
    
    required override init() {
        super.init()
    }

}
