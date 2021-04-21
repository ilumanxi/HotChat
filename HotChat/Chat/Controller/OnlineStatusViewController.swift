//
//  OnlineStatusViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import PanModal

class OnlineStatusViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}


extension OnlineStatusViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        
        if traitCollection.verticalSizeClass == .compact {
            
        }
        
        let scale: CGFloat = 407.0 / 667.0
        
        return .contentHeight(UIScreen.main.bounds.height * scale)
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5)
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

