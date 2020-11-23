//
//  App.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


public let CFBundleShortVersionString: String = "CFBundleShortVersionString"

extension Bundle {
    
    var appVersion: String {
        return infoDictionary?[CFBundleShortVersionString] as! String
    }
    
}



extension UIDevice {
    
    var identifier: String {
        
        do {
            return try KeychainItem(service: "com.friday.Chat", account: "deviceIdentifier").readItem()
        } catch  {
            var deviceIdentifier = identifierForVendor?.uuidString ?? ""
            deviceIdentifier = deviceIdentifier.replacingOccurrences(of: "-", with: "")
            deviceIdentifier = deviceIdentifier.lowercased()
            try? KeychainItem(service: "com.friday.Chat", account: "deviceIdentifier").saveItem(deviceIdentifier)
            
            return deviceIdentifier
        }
    }
    
}
