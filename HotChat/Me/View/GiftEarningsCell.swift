//
//  GiftEarningsCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class GiftEarningsCell: UITableViewCell {
    
    @IBOutlet weak var giftImageview: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var energyLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
