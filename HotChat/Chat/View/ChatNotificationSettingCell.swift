//
//  ChatNotificationSettingCell.swift
//  HotChat
//
//  Created by 谭帆帆 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class ChatNotificationSettingCell: UITableViewCell {
    
   @IBOutlet weak var settingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingView.layer.shadowOpacity = 1
        settingView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        settingView.layer.shadowOffset = CGSize(width: -4, height: 2)
        settingView.layer.shadowRadius = 4
        settingView.layer.cornerRadius = 8
    }
    
}
