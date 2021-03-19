//
//  TopicListViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/17.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class TopicListViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 10
        backgroundColor = UIColor(hexString: "DDDDDD")
    }

    
    func set(_ model: GroupTopic)  {
        
        backgroundImageView.kf.setImage(with: URL(string: model.coverPic))
        statusImageView.isHidden = model.status.isHidden
        titleLabel.text = model.name
        
    }
}
