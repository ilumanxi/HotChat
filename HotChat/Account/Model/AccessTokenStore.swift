//
//  AccessTokenStore.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation

public struct HotChatNotificationKey {}

extension HotChatNotificationKey {
    
    /// A user information key for an old access token value.
    public static let oldAccessToken = "oldAccessToken"
    
    /// A user information key for a new access token value.
    public static let newAccessToken = "newAccessToken"
}

extension Notification.Name {

    public static let HotChatAccessTokenDidUpdate = Notification.Name("com.friday.Chat.AccessTokenDidUpdate")
    

    public static let HotChatAccessTokenDidRemove = Notification.Name("com.friday.Chat.AccessTokenDidRemove")
}


class AccessTokenStore {
    
    let keychainStore: KeychainStore
    
    
    /// Keychain service name of the token version.
    var keychainService: String = "com.friday.Chat.tokenstore.\(Bundle.main.bundleIdentifier ?? "")"
    
    var keychainTokenKey: String  = "com.friday.Chat.tokenstore.tokenKey"
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    
    static let shared: AccessTokenStore = AccessTokenStore()
    
    
    init() {
       let keychainStore = KeychainStore(service: keychainService)
       self.keychainStore = keychainStore
        
        do {
            current = try keychainStore.value(for: keychainTokenKey, using: decoder)
        } catch {
            Log.print("Error happened during loading token from token store: \(error)")
            Log.print("HotChat recovered from it but your user might need another authorization to HotChat SDK.")
        }
    }
    
    
    /// The `AccessToken` object currently in use.
    public private(set) var current: AccessToken?
    
    func setCurrentToken(_ token: AccessToken) throws {
        guard current != token else { return }
        
        
        try keychainStore.set(token, for: keychainTokenKey, using: encoder)
        
        var userInfo = [HotChatNotificationKey.newAccessToken: token]
        if let old = current {
            userInfo[HotChatNotificationKey.oldAccessToken] = old
        }
        current = token
        
        NotificationCenter.default.post(name: .HotChatAccessTokenDidUpdate, object: token, userInfo: userInfo)
    }
    
    func removeCurrentAccessToken() throws {
        
        if try keychainStore.contains(keychainTokenKey) {
            try keychainStore.remove(keychainTokenKey)
            
            // TODO: We need to consider the location of setting `nil` carefully.
            // In normal case if keychainStore works well, everything should be fine.
            // But what will happen if revoke request succeeded, then keychain operation fails?
            // Do we want to keep `current` token or should be put it outside the if statement
            // and always reset it?
            let token = current
            current = nil
            NotificationCenter.default.post(name: .HotChatAccessTokenDidRemove, object: token, userInfo: nil)
        }
    }
    
}
