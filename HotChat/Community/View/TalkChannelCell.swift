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
    
    
    
    @IBOutlet weak var statusCornerView: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var authenticateImageView: UIImageView!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        // Initialization code
    }
    
    func set(model: User) {
        
        avatarImageView.kf.setImage(with: URL(string: model.headPic))
        
        statusCornerView.backgroundColor  = model.onlineStatus.imColor
        statusLabel.text = model.onlineStatus.imText
        statusLabel.textColor = model.onlineStatus.imColor
        
        ageLabel.text = "\(model.age)岁"
        
        if model.nick.length > 7 {
           
            nameLabel.text = "\(model.nick.prefix(6))..."
        }
        else {
            nameLabel.text = model.nick
        }
        
       
        

        authenticateImageView.isHidden =  model.authenticationStatus != .ok
        newcomerImageView.isHidden = !model.isNewDraw
    }

}
