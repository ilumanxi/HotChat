//
//  MediaViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/12.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


class MediaViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var playImageView: UIImageView!
    
    @IBOutlet weak var moreButton: UIButton!
    
    
    override func awakeFromNib() {
//        selectedBackgroundView = UIView()
        super.awakeFromNib()
        
        moreButton.isHidden = true
        
    }
    
    
    
}
