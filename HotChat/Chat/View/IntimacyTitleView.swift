//
//  IntimacyTitleView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/23.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class IntimacyTitleView: UIButton {
    
    
    @IBOutlet weak var leftImageView: UIImageView!
    
    
    @IBOutlet weak var rightImageView: UIImageView!
    
    
    @IBOutlet weak var textButton: UILabel!
    

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 110, height: 44)
    }
    
    func set(_ otherUser: User) {
        let user = LoginManager.shared.user!
        leftImageView.kf.setImage(with: URL(string: user.headPic))
        rightImageView.kf.setImage(with: URL(string: otherUser.headPic))
    }

}
