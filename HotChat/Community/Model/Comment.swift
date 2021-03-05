//
//  Comment.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/5.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON

class Comment: NSObject, HandyJSON {
    
    var commentId: String = ""
    /// 评论人
    var userInfo: User!
    /// 被回复人
    var toUserInfo: User?
    var nextList: [Comment] = []
    var content: String = ""
    var timeFormat: String?
    var zanNum: Int = 0
    var isSelfZan: Bool = false
    /// 回复总数
    var childCommentCount: Int = 0
    
    
    /// 分页
    
    
    // 默认 1
    var nextPage: Int = 1
    
    // 铺开
    var isExpanded: Bool = false
    
    // 回复加载完成
    var isAllLoad: Bool = false
    

    
    required override init() {
        super.init()
    }
    
}
