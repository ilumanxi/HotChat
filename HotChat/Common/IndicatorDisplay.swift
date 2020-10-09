//
//  Wireframe.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toast_Swift

protocol IndicatorDisplay {
    
    func show(_ message: String?, in view: UIView)
    
    func showIndicator(in view: UIView)
    func hideIndicator(from view: UIView)
}


extension IndicatorDisplay where Self: UIViewController {
    
    func show(_ message: String?) {
        show(message, in: view)
    }
    
    func showIndicator() {
       showIndicator(in: view)
    }
    
    func hideIndicator() {
        hideIndicator(from: view)
    }
    
    func showMessageOnWindow(_ message: String?) {
        show(message, in: UIApplication.shared.keyWindow ?? view)
    }
    
    func showIndicatorOnWindow() {
        showIndicator(in: UIApplication.shared.keyWindow ?? view)
    }
    
    func hideIndicatorFromWindow() {
        hideIndicator(from: UIApplication.shared.keyWindow ?? view)
    }
    
    func show(_ message: String?, in view: UIView) {
        view.endEditing(true)
        view.makeToast(message, position: .center)
    }
    
    func showIndicator(in view: UIView) {
        let hub  = MBProgressHUD.showAdded(to: view, animated: true)
        hub.show(animated: true)
    }
    
    func hideIndicator(from view: UIView) {
        let hub = view.subviews.first { $0 is MBProgressHUD } as? MBProgressHUD
        hub?.hide(animated: true)
    }
    
}
