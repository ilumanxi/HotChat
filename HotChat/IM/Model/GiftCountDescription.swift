//
//  GiftCountDescription.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/17.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import HandyJSON

@objc class GiftCountDescription: NSObject, HandyJSON {

//    var id: String = ""
    @objc var num: Int = 0
    @objc var name: String = ""
    
    required override init() {
        super.init()
    }
}
