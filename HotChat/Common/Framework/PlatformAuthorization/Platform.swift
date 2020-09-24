//
//  Platform.swift
//  Share
//
//  Created by 风起兮 on 2019/6/12.
//  Copyright © 2019 风起兮. All rights reserved.
//

import Foundation




enum AppType: Int {
    case wechat
}


enum PlatformType: Int {
    case wechatSession
    case wechatTimeline
}

enum AuthorizationError: Swift.Error {
    case cancel
    case notInstalled
    case authorize
    case network
    case failed(reason: Swift.Error)
}


/*
public struct AccessToken {
    
    /// The value of the access token.
    public let value: String
    
    let expiresIn: TimeInterval
    
    /// The creation time of the access token. It is the system time of the device that receives the current
    /// access token.
    public let createdAt: Date
    

    
    /// The refresh token bound to the access token.
    public let refreshToken: String
    
    
    /// The expiration time of the access token. It is calculated using `createdAt` and the validity period
    /// of the access token. This value might not be the actual expiration time because this value depends
    /// on the system time of the device when `createdAt` is determined.
    public var expiresAt: Date {
        return createdAt.addingTimeInterval(expiresIn)
    }
}
 */

struct AuthorizationUser {
    
    enum Gender: Int {
        case unknown = 0
        case male = 1
        case female = 2
    }
    
    var nickname: String
    var gender: Gender
    var birthday: Date?
    var userID: String
    var accessToken: String
    var pictureURL: URL?
    
}

