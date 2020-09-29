//
//  RelationshipViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class RelationshipViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    
    @IBOutlet weak var sexView: LabelView!
    
    
    @IBOutlet weak var introduceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    @IBAction func followAction(_ sender: Any) {
    }
    
    
}
