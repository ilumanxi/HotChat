//
//  Product.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON


struct Product: HandyJSON {
    
    var moneyId: String = ""
    var energy: Int = 0
    var money: NSDecimalNumber!
    var title: String = ""
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            money <-- NSDecimalNumberTransform()
    }
}


struct Ordrer: HandyJSON {

    
    var outTradeNo: String!
    var payType: String = ""
    var amount: String = ""
    var subject: String = ""
    
}


extension Dictionary: HandyJSON {
    
}
