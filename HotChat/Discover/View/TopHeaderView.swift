//
//  TopHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/9.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class TopHeaderView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var backgroundView: GradientView!
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var top1AvatarImageView: UIImageView!
    @IBOutlet weak var top1NameLabel: UILabel!
    @IBOutlet weak var top1CountLabel: UILabel!
    
    @IBOutlet weak var top2AvatarImageView: UIImageView!
    @IBOutlet weak var top2NameLabel: UILabel!
    @IBOutlet weak var top2CountLabel: UILabel!
    
    @IBOutlet weak var top3AvatarImageView: UIImageView!
    @IBOutlet weak var top3NameLabel: UILabel!
    @IBOutlet weak var top3CountLabel: UILabel!
    
    
    let onAvatarTapped = Delegate<Int, Void>()
    
    @IBAction func top1AvatarTapped(_ sender: Any) {
        onAvatarTapped.call(0)
    }
    
    @IBAction func top2AvatarTapped(_ sender: Any) {
        onAvatarTapped.call(1)
    }
    
    @IBAction func top3AvatarTapped(_ sender: Any) {
        onAvatarTapped.call(2)
    }
    
}
