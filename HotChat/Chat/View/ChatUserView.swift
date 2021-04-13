//
//  ChatUserView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/12.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class ChatUserView: UIView {
    
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    
    
    @IBOutlet weak var avatarView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sexButton: SexButton!
    
    @IBOutlet weak var followButton: GradientButton!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var constellationLabel: UILabel!
    
    @IBOutlet weak var introductionLabel: UILabel!
    
    
    @IBOutlet weak var authenticationView: UIImageView!
    
    let onFollowTapped = Delegate<Void, Void>()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        infoView.isHidden = true
    }
    
    
    @IBAction func followButtonTapped(_ sender: Any) {
        onFollowTapped.call()
    }
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        return systemLayoutSizeFitting(size, withHorizontalFittingPriority: UILayoutPriority(900), verticalFittingPriority: .fittingSizeLevel)
    }
    
    override func sizeToFit() {
        
        let size = sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height))
        
        frame = CGRect(origin: .zero, size: size)
    }
}


extension ChatUserView {
    
    func set(_ user: User) {
        infoView.isHidden = false
        avatarView.kf.setImage(with: URL(string: user.headPic))
        nameLabel.text = user.nick
        sexButton.set(user)
        followButton.isHidden = user.isFollow
        locationLabel.text = "所在地：\(user.region)"
        constellationLabel.text = "星座： \(user.constellation)"
        introductionLabel.text = user.introduce
        authenticationView.isHidden = user.authenticationStatus != .ok
    }
}
