//
//  InterflowCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class InterflowCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sexButton: SexButton!
    
    @IBOutlet weak var gradeImageView: UIImageView!
    
    @IBOutlet weak var intimacyLabel: UILabel!
    
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var statusButton: UIButton!
    
    func set(_ model: Interflow) {
        
        let user = model.userInfo!
        
        avatarImageView.kf.setImage(with: URL(string: user.headPic))
        nameLabel.text = user.nick
        sexButton.set(user)
        gradeImageView.setGrade(user)
        let formattter = NumberFormatter()
        let string = formattter.string(from: NSNumber(value: user.userIntimacy))!
        intimacyLabel.text = "亲密度\(string)℃"
        timeButton.setTitle(model.timeFormat, for: .normal)
        statusButton.isHidden = user.onlineStatus == .offline
    }
    
}
