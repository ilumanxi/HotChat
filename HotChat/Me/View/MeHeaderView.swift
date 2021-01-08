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
    
    @IBOutlet weak var sexView: LabelView!
    
    @IBOutlet weak var gradeView: LabelView!
    
    @IBOutlet weak var vipButton: UIButton!
    
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var fansButton: UIButton!
    
    @IBOutlet weak var taskView: UIStackView!
    
    @IBOutlet weak var walletView: UIStackView!
    
    @IBOutlet weak var earningsView: UIStackView!
    
    @IBOutlet weak var vipView: UIStackView!
    
    @IBOutlet weak var inviteView: UIStackView!
    
    
    @IBOutlet var backgroundViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            backgroundViewHeightConstraint.constant = 204 + 44 + UIApplication.shared.statusBarFrame.height
        }
    }
    
//    override class var requiresConstraintBasedLayout: Bool {
//        return true
//    }

    
    override func awakeFromNib() {
        
//        translatesAutoresizingMaskIntoConstraints = false
        
        if let superview = superview {
            widthAnchor.constraint(equalTo: superview.widthAnchor).isActive = true
        }
        
        // 可以根据 srollview offset 改变高度
        backgroundViewHeightConstraint.constant = 204 + 44 + UIApplication.shared.statusBarFrame.height
        
        super.awakeFromNib()
    }
    
}
