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
    
    var girlStatus: ValidationStatus = .empty
    
    var headStatus: ValidationStatus = .empty
    
    var realNameStatus: ValidationStatus = .empty
    
    var contactStatus: ValidationStatus = .empty
}
