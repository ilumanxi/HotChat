//
//  Wireframe.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol Wireframe {
    
    func show(_ message: String)
}


extension Wireframe where Self: UIViewController {
    
    func show(_ message: String) {
        let hub = MBProgressHUD.showAdded(to: view, animated: true)
        hub.mode = .text
        hub.label.text = message
        hub.hide(animated: true, afterDelay: 3)
    }
    
    
}

var HotChatHubKey = "HotChatHubKey"

extension UIViewController {
    
    var hub: MBProgressHUD? {
        get {
            guard let hub = objc_getAssociatedObject(self, &HotChatHubKey) as? MBProgressHUD else {
                return nil
            }
            return hub
        }
        set {
            objc_setAssociatedObject(self, &HotChatHubKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    
}
