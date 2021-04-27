//
//  IntimacyCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class IntimacyCell: UITableViewCell {

   
    @IBOutlet weak var intimacyImageView: UIImageView!

    @IBOutlet weak var lockImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var currenStatusButton: UIButton!
    
    @IBOutlet weak var intimacyTextLabel: UIButton!
    
    @IBOutlet weak var explainLabel: UILabel!
    
    @IBOutlet weak var intimacyButton: UIButton!
    
    
    func set(_ model: IntimacyInfo) {
        
        intimacyImageView.kf.setImage(with: URL(string: model.icon))
        lockImageView.isHidden = model.status != .normal
        nameLabel.text = model.name
        explainLabel.text = model.explain
        
        currenStatusButton.isHidden = model.status != .currentDeblocking
        
        let formatter = NumberFormatter()
        let string = formatter.string(from: NSNumber(value: model.intimacy))!
        intimacyButton.setTitle("\(string)℃", for: .normal)
    }
    
    
}
