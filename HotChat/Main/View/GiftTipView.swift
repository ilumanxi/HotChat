//
//  GiftTipView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class GiftTipView: UIView {

   
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var sexButton: GradientButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationButton: HotChatButton!
    
    @IBOutlet weak var moneyLabel: UILabel!
    
    
    let onCloseTapped = Delegate<Void, Void>()
    let onChatTapped = Delegate<Void, Void>()
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        onCloseTapped.call()
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        onChatTapped.call()
    }
    
}
