//
//  TalkTop.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON


class TalkTop: NSObject, HandyJSON {
    
    required override init() {
        
    }
    
    /// 富豪/豪气
    var consumeList: [User] = []
    
    /// 魅力榜
    var incomeList: [User] = []
    
    
    
}

extension TalkTop {
    var data: [TalkTypeTop] {
        var list: [TalkTypeTop] = []
        
        list.append(TalkTypeTop(type: .estate, users: consumeList))
        list.append(TalkTypeTop(type: .charm, users: incomeList))
        
        return list
    }
}

extension TopType {
    
    var typeImage: UIImage? {
        switch self {
        case .charm:
            return UIImage(named: "charm")
        case .estate:
            return UIImage(named: "estate")
        case .intimate:
            return nil
        }
    }
    
}

struct TalkTypeTop {
  
    let type: TopType
    let users: [User]
    init(type: TopType, users: [User]) {
        self.type = type
        self.users = users
    }
}


//
