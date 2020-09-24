//
//  Bundle+App.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import Foundation


public let CFBundleShortVersionString: String = "CFBundleShortVersionString"

extension Bundle {
    
    var appVersion: String {
        return infoDictionary?[CFBundleShortVersionString] as! String
    }
    
}
