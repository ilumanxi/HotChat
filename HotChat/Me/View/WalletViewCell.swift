//
//  WalletViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class WalletViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var energyLabel: UILabel!
    
    @IBOutlet weak var tCoinLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
