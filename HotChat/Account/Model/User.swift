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

@objc enum Sex: Int, HandyJSONEnum, CustomStringConvertible {
    case empty = 0
    case male = 1
    case female = 2

    var image: UIImage? {
        switch self {
        case .male:
            return UIImage(named: "me-sex-man")
        case .female:
            return UIImage(named: "me-sex-woman")
        case .empty:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .male:
            return "男生"
        case .female:
            return "女生"
        case .empty:
            return "未知"
        }
    }
}

enum UserStatus: Int, HandyJSONEnum {
   ///  用户状态 1正常
    case normal = 1
}


enum OnlineStatus: Int, HandyJSONEnum {
    /// 离线
    case offline = 0
    /// 在线
    case online = 1
    /// 直播中
    case living = 2
}

enum ValidationStatus: Int, HandyJSONEnum {
    /// 未认证
    case empty = 0
    /// 审核中
    case validating = 2
    /// 审核通过
    case ok = 1
    /// 审核失败
    case failed = 3
}

extension ValidationStatus {
    
    var isPresent: Bool {
        return self == .ok
    }
    
}

enum VipType: Int, HandyJSONEnum {
    /// 普通用户
    case empty = 0
    /// 会员
    case month = 1
    /// 季会员
    case quarter = 2
    /// 年会员
    case year = 3
}



@objc public class User: NSObject, HandyJSON {
    
    required public override init() {
        super.init()
    }
    
    class Photo: NSObject, HandyJSON {
        var picId: Int = 0
        var picUrl: String = ""
        required override init() {
            super.init()
        }
    }
    
    @objc var userId: String = ""
    @objc var token: String = ""
    var status: Int = 0
    var isInit: Bool = false
    var isFollow: Bool = false
    
    /// IM
    
    var imUserSig: String = ""
    var imExpire: TimeInterval = 0
    
    ///  能量
    @objc var userEnergy: Int = 0
    
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
    
    /// 主播
    var girlStatus: Bool =  false
    
    /// 黑名单
    var isDefriend: Bool = false
    
    /// 隐私设置
    var userSettings: InfoSettings = InfoSettings()
    
    /// 在线状态
    var onlineStatus: OnlineStatus = .offline
    
    var authenticationStatus: ValidationStatus = .empty
    
    /// 头像认证
    var headStatus: ValidationStatus = .empty
    
    /// 实名认证
    var realNameStatus: ValidationStatus = .empty
    
    /// VIP
    var vipType: VipType = .empty
    
    
    /// 用户状态
    var userStatus: UserStatus = .normal
    
    
    /// 手机号
    var phone: String = ""
    
    /// 位置
    var region: String = "未知距离"
    
    ///  头像
    var headPic: String = ""
    
    //  相册
    var photoList: [Photo] = []
    
    ///  生日
    var birthday: TimeInterval = 0
    
    /// 年龄
     @objc var age: Int = 0
    
    var sex: Sex = .empty
    
    @objc var ocSex: Int {
        return sex.rawValue
    }
    
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
