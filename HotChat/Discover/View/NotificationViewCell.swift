//
//  NotificationViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var timeFormaLabel: UILabel!
    
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var eventLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!


    @IBOutlet weak var mediaView: UIView!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    
    @IBOutlet weak var mediaPlayView: UIImageView!
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    
    func set(_ model: Notice) {
        
        eventLabel.text = nil
        eventImageView.image = nil
        
        let user = model.userInfo!
        let data = model.data!
        
        avatarButton.kf.setImage(with: URL(string: user.headPic), for: .normal)
        nicknameLabel.text = user.nick

        
        if model.eventType == 1 { //评论
            eventLabel.text = model.content
            eventLabel.isHidden = false
            eventImageView.isHidden = true
        }
        else if model.eventType == 2 { //点赞
            eventImageView.image = UIImage(named: "like-selected")
            mediaView.isHidden = false
            mediaImageView.kf.setImage(with: URL(string: model.data!.coverUrl))
            mediaPlayView.isHidden = data.type != .video
            eventLabel.isHidden = true
            eventImageView.isHidden = false
        }
        else if model.eventType == 3 { //礼物
            eventLabel.text = model.content
            eventLabel.isHidden = false
            eventImageView.isHidden = true
        }
        
        timeFormaLabel.text = model.timeFormat
        statusLabel.isHidden = model.isRead
    }
    
}
