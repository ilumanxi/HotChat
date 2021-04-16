//
//  EngagementViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/15.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class DatingViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var statusView: UIView!
    
    
    @IBOutlet weak var sexButton: SexButton!
    
    @IBOutlet weak var bottomView: GradientView!
    
    @IBOutlet weak var introduceLabel: UILabel!
    
    
    override func awakeFromNib() {
        bottomView.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0),
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)]
        bottomView.locations = [0, 1]
        bottomView.startPoint = CGPoint(x: 0.5, y: 0)
        bottomView.endPoint = CGPoint(x: 0.5, y: 1)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        super.awakeFromNib()
    }

}

extension DatingViewCell {
    
    func set(_ model: Dynamic) {
        
        let user = model.userInfo!
        
        avatarImageView.kf.setImage(with: URL(string: user.headPic))
        priceLabel.text = "\(user.videoCharge)能量/分钟"
        nameLabel.text = user.nick
        sexButton.set(user)
        introduceLabel.text = user.introduce
        
    }
}
