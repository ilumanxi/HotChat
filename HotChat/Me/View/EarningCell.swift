//
//  EarningCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/19.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class EarningCell: UITableViewCell {
    
    
    
    @IBOutlet weak var currentMonthEnergyLabel: UILabel!
    
    @IBOutlet weak var currentMonthTCoinLabel: UILabel!
    
    
    @IBOutlet weak var lastMonthEnergyLabel: UILabel!
    
    @IBOutlet weak var lastMonthTCoinLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
