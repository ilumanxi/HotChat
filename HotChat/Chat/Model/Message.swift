//
//  Messsage.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/13.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON

struct Message: HandyJSON {
    var userId: String = ""
    var isFollow: Bool = false
    var labelList: [LikeTag] = []
    var headPic: String = ""
    var nick: String = ""
    var content: String = ""
    var age: Int = 0
}
