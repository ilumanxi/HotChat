//
//  ListViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/23.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import FSPagerView
import Kingfisher

class ListViewCell: FSPagerViewCell {
    
    
    @IBOutlet weak var top1AvatarMaskView: UIImageView!
    
    @IBOutlet weak var top1AvatarImageView: UIImageView!
    @IBOutlet weak var top2AvatarImageView: UIImageView!
    @IBOutlet weak var top3AvatarImageView: UIImageView!
    
    @IBOutlet weak var typeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.layer.shadowColor = UIColor.clear.cgColor
        self.contentView.layer.shadowRadius = 5
        self.contentView.layer.shadowOpacity = 0.75
        self.contentView.layer.shadowOffset = .zero
    }
    
    func set(model: TalkTypeTop)  {
        
        
        typeImageView.image = model.type.typeImage
        
        top1AvatarMaskView.isHidden = model.users.isEmpty
        
        let imageViews = [top1AvatarImageView, top2AvatarImageView, top3AvatarImageView]
        
        imageViews.forEach { $0?.isHidden = true }
        
        for (index, user) in model.users.enumerated() {
            
            let imageView = imageViews[index]
            imageView?.kf.setImage(with: URL(string: user.headPic))
            imageView?.isHidden = false
        }
    }

}
