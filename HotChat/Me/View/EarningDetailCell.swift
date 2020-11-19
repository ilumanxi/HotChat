//
//  EarningDetailCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/19.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class EarningDetailCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var containerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
