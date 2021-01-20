//
//  Product.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON
import StoreKit

struct Product: HandyJSON {
    
    var moneyId: String = ""
    var energy: Int = 0
    var money: NSDecimalNumber!
    var title: String = ""
    
    var isFirstRecharge: Bool = false
    var giveEnergy: String = ""
    var vipDay: String = ""
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            money <-- NSDecimalNumberTransform()
    }
}


struct ItemProduct {
    
    let product: Product
    let appleProduct: SKProduct
}

struct Ordrer: HandyJSON {
    
    var outTradeNo: String!
    var payType: String = ""
    var amount: String = ""
    var subject: String = ""
    
    var itemProduct: ItemProduct!
}


extension Dictionary: HandyJSON {
    
}
