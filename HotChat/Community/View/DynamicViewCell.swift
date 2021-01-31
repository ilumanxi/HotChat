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
    
    
    @IBOutlet weak var typeImageView: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var regionButton: HotChatButton!
    
    @IBOutlet weak var bottomView: GradientView!
    
    override func awakeFromNib() {
        bottomView.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0),
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)]
        bottomView.locations = [0, 1]
        bottomView.startPoint = CGPoint(x: 0.5, y: 0)
        bottomView.endPoint = CGPoint(x: 0.5, y: 1)
        
        super.awakeFromNib()
    }
    
    let onLikeClicked = Delegate<DynamicViewCell, Void>()
    
    @IBAction func likeAction(_ sender: Any) {
        onLikeClicked.call(self)
    }
    
}
