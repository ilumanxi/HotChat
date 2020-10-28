//
//  SeparatorLine.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
/**
 A UIView thats intrinsicContentSize is overrided so an exact height can be specified
 

 1. Default height is 1 pixel
 2. Default backgroundColor is UIColor.lightGray
 */

@IBDesignable
class SeparatorLine: UIView {
    
    // MARK: - Properties
    
    /// The height of the line
    @IBInspectable
   var pixel: CGFloat = 1.0 / UIScreen.main.scale {
        didSet {
            constraints.filter { $0.identifier == "height" }.forEach { $0.constant = pixel } // Assumes constraint was given an identifier
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: pixel)
    }
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Sets up the default properties
    open func setup() {
        if #available(iOS 13, *) {
            backgroundColor = .systemGray2
        } else {
            backgroundColor = .lightGray
        }
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

