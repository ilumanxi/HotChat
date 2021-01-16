//
//  WalletProducItemCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/16.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class WalletProducItemCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    var item: ItemProduct!{
        didSet {
            titleLabel.text = item.appleProduct.localizedTitle
            priceLabel.text = item.appleProduct.localizedPrice
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.borderWidth = 0.5
        layer.masksToBounds = true
        layer.cornerRadius = 10
        isSelected = false
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor(hexString: "#5159F8").cgColor
            }
            else {
                layer.borderColor = UIColor(hexString: "#F4F4F4").cgColor
            }
        }
    }
    
}
