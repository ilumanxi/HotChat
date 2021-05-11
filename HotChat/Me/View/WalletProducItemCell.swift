//
//  WalletProducItemCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/16.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class WalletProducItemCell: UICollectionViewCell {
    
    
    @IBOutlet weak var firstRechargeImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    @IBOutlet weak var textLabel: UILabel!
    
    var item: ItemProduct!{
        didSet {
            firstRechargeImageView.isHidden = !item.product.isFirstRecharge
            titleLabel.text = item.appleProduct.localizedTitle
            priceLabel.text = item.appleProduct.localizedPrice
            textLabel.isHidden = !item.product.isFirstRecharge
            
            if !item.product.giveEnergy.isEmpty  || !item.product.vipDay.isEmpty {
                textLabel.text = "赠送\(item.product.giveEnergy)能量+\(item.product.vipDay)天会员"
            }
            else {
                textLabel.text = nil
            }
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
                layer.borderColor = UIColor(hexString: "#FF433E").cgColor
            }
            else {
                layer.borderColor = UIColor(hexString: "#F4F4F4").cgColor
            }
        }
    }
    
}
