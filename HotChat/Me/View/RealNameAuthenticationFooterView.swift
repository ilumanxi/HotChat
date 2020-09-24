//
//  RealNameAuthenticationFooterView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class RealNameAuthenticationFooterView: UIView {
    
    
    @IBOutlet weak var contentView: UIView!
    
    
//
//    override class var requiresConstraintBasedLayout: Bool {
//        return true
//    }

    
    override func awakeFromNib() {
        
//        translatesAutoresizingMaskIntoConstraints = false
        
        contentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
//        widthAnchor.constraint(equalTo: superview!.widthAnchor).isActive = true
        
        super.awakeFromNib()
    }
}
