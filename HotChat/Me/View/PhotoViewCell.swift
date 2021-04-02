//
//  PhotoViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/2.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import FSPagerView

class PhotoViewCell: FSPagerViewCell {

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

}
