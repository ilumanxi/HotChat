//
//  ChannelCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/15.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {
   
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var vipButton: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var introduceLabel: UILabel!
    
    @IBOutlet weak var sexView: SexButton!
    
    @IBOutlet weak var authenticationButton: UIButton!
    
    @IBOutlet weak var gradeView: UIImageView!
    
}


extension ChannelCell {
    
    func setUser(_ user: User) {
       avatarImageView.kf.setImage(with: URL(string: user.headPic))
       nicknameLabel.text = user.nick
       nicknameLabel.textColor = user.vipType.textColor
       sexView.set(user)
       locationLabel.text = user.region
       introduceLabel.text = user.introduce
       statusLabel.text = user.onlineStatus.text
       statusLabel.textColor = user.onlineStatus.color
       vipButton.setVIP(user.vipType)
       gradeView.setGrade(user)
       authenticationButton.isHidden = !user.girlStatus
    }
}
