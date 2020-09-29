//
//  WalletProductViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class WalletProductViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var priceButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
