//
//  User.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/23.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation
import HandyJSON

extension Array: HandyJSON {
    
}

struct LikeTag: HandyJSON, Equatable {
    
    var id: Int = 0
    var label: String = ""
    var type: Int = 0
    var isCheck: Bool = false
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        return lhs.id == rhs.id
    }
}

struct Topic: HandyJSON {
    
    var id: Int = 0
    var questionId: Int = 0
    var labelId: Int = 0
    var label: String = ""
    var content: String  = ""
    
}

enum Sex: Int, HandyJSONEnum, CustomStringConvertible {
    case male = 1
    case female = 2

    var image: UIImage? {
        switch self {
        case .male:
            return R.image.meSexMan()
        case .female:
            return R.image.meSexWoman()
        }
    }
    
    var description: String {
        switch self {
        case .male:
            return "男生"
        case .female:
            return "女生"
        }
    }
}


struct User: HandyJSON {
    
    struct Photo: HandyJSON {
        var picId: Int = 0
        var picUrl: String = ""
    }
    
    var userId: String = ""
    var token: String = ""
    var status: Int = 0
    var isInit: Bool = false
    
    //  能量
    var userEnergy: Int = 0
    
    // 贪币
    var userTanbi: Int = 0
    
    //  甜豆
    var userSweetpea: Int = 0
    
    //  关注
    var userFollowNum: Int = 0
    
    //  房间ID  IM
    var roomID: String = ""
    
    // 粉数
    var userFansNum: Int = 0
    
    // 介绍
    var introduce: String = ""
    
    // 行业
    var industryList: [LikeTag] = []
    
    //  昵称
    var nick: String = ""
    
    //  头像
    var headPic: String = ""
    
    //  相册
    var photoList: [Photo] = []
    
    //  生日
    var birthday: TimeInterval = 0
    
    var sex: Sex?
    
    //  喜欢的ta
    var labelList: [LikeTag] = []
    
    // 小编专访
    var tipsList: [Topic] = []
    
    
    // 我的爱好
    
    // 运动
    var motionList: [LikeTag] = []
    
    // 食物
    var foodList: [LikeTag] = []
    
    // 音乐
    var musicList: [LikeTag] = []
    
    // 书籍
    var bookList: [LikeTag] = []
    
    // 旅行
    var travelList: [LikeTag] = []
    
    // 电影
    var movieList: [LikeTag] = []
    
    
}
