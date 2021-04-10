//
//  ContactInfo.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/9.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON


struct ContactStatus: HandyJSON {
    
    var status: ValidationStatus = .empty
    var value: String = ""
}

struct ContactInfo: HandyJSON {
    
    var qq: ContactStatus?
    
    var weixin: ContactStatus?
    
    var contactPhone: ContactStatus?
    
}
