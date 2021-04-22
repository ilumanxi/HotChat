//
//  OnlineStatusCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class OnlineStatusCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var onlineButton: UIButton!
    
    @IBOutlet weak var newcomerButton: UIButton!
    
    @IBOutlet weak var gradeView: UIImageView!
    
    @IBOutlet weak var vipButton: UIButton!
    
    
    @IBOutlet weak var sexButton: SexButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    let onChat = Delegate<Void, Void>()
    
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        onChat.call()
    }
    
    
    func set(_ model: PushItem)  {
        
        if model.isConnect {
            statusLabel.text = "*已联系"
            statusLabel.textColor = UIColor(hexString: "#999999")
        }
        else {
            statusLabel.text = "*未联系"
            statusLabel.textColor = UIColor(hexString: "#FF403E")
        }
        
        let user = model.userInfo!
        avatarImageView.kf.setImage(with: URL(string: user.headPic))
        nameLabel.text = user.nick
        
        if user.onlineStatus == .offline {
            onlineButton.setTitle("离线", for: .normal)
            onlineButton.setTitleColor(UIColor(hexString: "#909090"), for: .normal)
            onlineButton.backgroundColor = UIColor(hexString: "#A3A3A3").withAlphaComponent(0.12)
        }
        else {
            onlineButton.setTitle("在线", for: .normal)
            onlineButton.setTitleColor(UIColor(hexString: "#2ECF98"), for: .normal)
            onlineButton.backgroundColor = UIColor(hexString: "#2ECF98").withAlphaComponent(0.12)
        }
        
        newcomerButton.isHidden = !user.isNewDraw
        
        sexButton.set(user)
        gradeView.setGrade(user)
        vipButton.setVIP(user.vipType)
        
        timeLabel.text = model.timeFormat
    }
    
}
