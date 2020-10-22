//
//  UserViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class UserViewCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var userView: LabelView!
    
    @IBOutlet weak var followView: LabelView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
}