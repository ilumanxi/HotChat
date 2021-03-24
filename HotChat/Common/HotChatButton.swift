//
//  HotChatButton.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/24.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

//@IBDesignable
class HotChatButton: UIButton {
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }


    @IBInspectable override var titleEdgeInsets: UIEdgeInsets {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable override var imageEdgeInsets: UIEdgeInsets {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width = size.width + imageEdgeInsets.left + imageEdgeInsets.right + titleEdgeInsets.left + titleEdgeInsets.right
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size  = super.sizeThatFits(size)
        size.width = size.width + imageEdgeInsets.left + imageEdgeInsets.right + titleEdgeInsets.left + titleEdgeInsets.right
        return size
    }

}
