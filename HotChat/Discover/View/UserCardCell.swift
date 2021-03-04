//
//  UserCardCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/3.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class UserCardCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var vipButton: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var statusView: GradientView!
    
    @IBOutlet weak var introduceLabel: UILabel!
    
    @IBOutlet weak var sexView: LabelView!
    
    @IBOutlet weak var authenticationButton: UIButton!
    
    @IBOutlet weak var gradeView: UIImageView!

}


extension UserCardCell {
    
    func setUser(_ user: User) {
       avatarImageView.kf.setImage(with: URL(string: user.headPic))
       nicknameLabel.text = user.nick
       nicknameLabel.textColor = user.vipType.textColor
       sexView.setSex(user)
       locationLabel.text = user.region
       introduceLabel.text = user.introduce
       statusView.backgroundColor = user.onlineStatus.color
       vipButton.setVIP(user.vipType)
        if user.girlStatus {
            vipButton.isHidden = true
        }
       gradeView.setGrade(user)
       authenticationButton.isHidden = !user.girlStatus
    }
}
