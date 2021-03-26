//
//  TalkChannelCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/24.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class TalkChannelCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var newcomerImageView: UIImageView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var authenticateImageView: UIImageView!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var introduceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        // Initialization code
    }
    
    func set(model: User) {
        
        avatarImageView.kf.setImage(with: URL(string: model.headPic))
        
        statusImageView.image = model.onlineStatus.image
        
        ageLabel.text = "\(model.age)岁"
        introduceLabel.text = model.introduce
        

        authenticateImageView.isHidden =  model.authenticationStatus != .ok
        newcomerImageView.isHidden = !model.isNewDraw
    }

}
