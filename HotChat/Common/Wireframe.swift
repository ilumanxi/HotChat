//
//  Wireframe.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Toast_Swift


protocol Wireframe {
    
    func show(_ message: String)
}


extension Wireframe where Self: UIViewController {
    
    func show(_ message: String) {
        view.makeToast(message, duration: 3, position: .top)
    }
}
