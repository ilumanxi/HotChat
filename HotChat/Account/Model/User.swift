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
            return UIImage(named: "me-sex-man")
        case .female:
            return UIImage(named: "me-sex-woman")
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
    var isFollow: Bool = false
    
    /// IM
    
    var imUserSig: String = ""
    var imExpire: TimeInterval = 0
    
    ///  能量
    var userEnergy: Int = 0
    
    /// 贪币
    var userTanbi: Int = 0
    
    ///  甜豆
    var userSweetpea: Int = 0
    
    ///  关注
    var userFollowNum: Int = 0
    
    ///  房间ID  IM
    var roomID: String = ""
    
    /// 粉数
    var userFansNum: Int = 0
    
    /// 介绍
    var introduce: String = ""
    
    /// 行业
    var industryList: [LikeTag] = []
    
    ///  昵称
    var nick: String = ""
    
    /// 备注
    var friendNick: String = ""
    
    
    /// 在线状态 1在线 2直播中

    var onlineStatus: Int = 0
    
    /// 认证状态 1在线 0未认证
    var authenticationStatus: Int = 0
    
    /// 位置
    var region: String = "未知距离"
    
    ///  头像
    var headPic: String = ""
    
    //  相册
    var photoList: [Photo] = []
    
    ///  生日
    var birthday: TimeInterval = 0
    
    /// 年龄
    var age: Int = 0
    
    var sex: Sex?
    
    ///  喜欢的ta
    var labelList: [LikeTag] = []
    
    /// 小编专访
    var tipsList: [Topic] = []
    
    
    // 我的爱好
    
    /// 运动
    var motionList: [LikeTag] = []
    
    /// 食物
    var foodList: [LikeTag] = []
    
    /// 音乐
    var musicList: [LikeTag] = []
    
    /// 书籍
    var bookList: [LikeTag] = []
    
    /// 旅行
    var travelList: [LikeTag] = []
    
    /// 电影
    var movieList: [LikeTag] = []
    
    
}
