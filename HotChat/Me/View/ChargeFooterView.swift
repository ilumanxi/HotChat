//
//  ChargeFooterView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/14.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class ChargeFooterView: UIView {

   
    let onTapped = Delegate<Void, Void>()
    
    @IBAction func buttonDidTapped(_ sender: Any) {
        onTapped.call()
    }
    
    func fittingSize()  {
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let size = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority(900), verticalFittingPriority: .fittingSizeLevel)
        frame = CGRect(origin: .zero, size: size)
    }
}
