//
//  ChatMemberCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/18.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class ChatMemberCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var sexView: LabelView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func set(_ model: User)  {
        avatarImageView.kf.setImage(with: URL(string: model.headPic))
        nameLabel.text = model.nick
        nameLabel.textColor = model.vipType.textColor
        sexView.setSex(model)
    }
    
}
