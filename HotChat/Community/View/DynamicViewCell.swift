//
//  DynamicViewCell.swift
//  HotChat
//
//  Created by 谭帆帆 on 2020/10/11.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class DynamicViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    
    @IBOutlet weak var regionButton: HotChatButton!
    
    let onLikeClicked = Delegate<DynamicViewCell, Void>()
    
    @IBAction func likeAction(_ sender: Any) {
        onLikeClicked.call(self)
    }
    
}
