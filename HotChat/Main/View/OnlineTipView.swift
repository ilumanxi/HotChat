//
//  OnlineTipView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class OnlineTipView: UIView {
    
    let onAvatarTapped = Delegate<Void, Void>()
    
    let onContentTapped = Delegate<Void, Void>()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBAction func avatarTapped(_ sender: Any) {
        
        onAvatarTapped.call()
    }
    
    @IBAction func contentTapped(_ sender: Any) {
        
        onContentTapped.call()
    }

}
