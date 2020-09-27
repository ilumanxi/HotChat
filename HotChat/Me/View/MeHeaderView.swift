//
//  MeHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class MeHeaderView: UIView {
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet var backgroundViewHeightConstraint: NSLayoutConstraint!
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    
    override func awakeFromNib() {
        
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: superview!.widthAnchor).isActive = true
        
        // 可以根据 srollview offset 改变高度
        backgroundViewHeightConstraint.constant = UIScreen.main.bounds.height
        
        super.awakeFromNib()
    }
    
}
