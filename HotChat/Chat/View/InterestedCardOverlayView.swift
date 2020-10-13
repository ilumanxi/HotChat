//
//  InterestedCardOverlayView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/11.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Koloda

class InterestedCardOverlayView: OverlayView {
    
    
    @IBOutlet weak var overlayImageView: UIImageView!
    
    open override func update(progress: CGFloat) {
        alpha = progress
    }
    
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: "chat-skip")
            case .right? :
                overlayImageView.image = UIImage(named: "chat-follow")
            default:
                overlayImageView.image = nil
            }
            
        }
    }

}
