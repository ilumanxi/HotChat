//
//  BlacklistCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/11.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class BlacklistCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    let onRemoveButtonTapped = Delegate<BlacklistCell, Void>()
    
    @IBAction func removeButtonTapped(_ sender: Any) {
        
        onRemoveButtonTapped.call(self)
    }
    
}
