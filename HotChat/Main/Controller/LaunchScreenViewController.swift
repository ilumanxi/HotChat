//
//  LaunchScreenViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/5/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit


class LaunchScreenWindow: UIWindow {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.windowLevel = .alert
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


fileprivate var launchScreenWindow: LaunchScreenWindow?

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}


extension LaunchScreenViewController {
    
   
    static func show() {
        if launchScreenWindow != nil {
            return
        }
        launchScreenWindow = LaunchScreenWindow(frame: UIScreen.main.bounds)
        launchScreenWindow?.rootViewController = LaunchScreenViewController()
        launchScreenWindow?.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            launchScreenWindow = nil
        }
    }
}





