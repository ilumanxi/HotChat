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
    
    enum CertificationStatus: Int, HandyJSONEnum, CustomStringConvertible{
        
        
        case unauthorized = 0
        case authorized = 1
        case inReview = 2
        
        var description: String {
            switch self {
            case .unauthorized:
                return "未认证"
            case .inReview:
                return "审核中"
            case .authorized:
                return "已认证"
            }
        }
        
       
    }
    
    var certificationStatus: CertificationStatus = .unauthorized
    
    var userName: String = ""
    
    var identityNum: String = ""
    
    var identityPicFront: String = ""
    
    var identityPicFan: String = ""
    
}
