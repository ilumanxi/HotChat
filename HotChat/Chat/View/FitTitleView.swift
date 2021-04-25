//
//  FitTitleView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class FitTitleView: UIView {
    
    func setLayouSize(titles: [String], font: UIFont, spacing: CGFloat)  {
        
        let width = titles
            .map {
                ($0 as NSString).textSize(in: UIView.layoutFittingExpandedSize, font: font).width
            }
            .max()! + 1
        let contentWidth = width + CGFloat( max(0,titles.count - 1)) * spacing
        layouSize = CGSize(width: contentWidth, height: UIView.layoutFittingExpandedSize.height)
    }
    
    var layouSize: CGSize = UIView.layoutFittingExpandedSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }


    override var intrinsicContentSize: CGSize {
        return layouSize
    }

}
