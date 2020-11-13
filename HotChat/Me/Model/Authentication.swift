//
//  Authentication.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import HandyJSON


struct Authentication: HandyJSON {

    /// 实名认证
    var certificationStatus: ValidationStatus = .empty
    
    var userName: String = ""
    
    var identityNum: String = ""
    
    var identityPicFront: String = ""
    
    var identityPicFan: String = ""
    
    var handIdentityPic: String = ""
    
}
