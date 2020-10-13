//
//  App.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/31.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import DynamicColor
import Reusable


extension UIColor {
    
    
    static let theme: UIColor = UIColor(hexString: "#525AF8")
    
    static let separator: UIColor = UIColor(hexString: "#F7F6F6")
    
    static let titleBlack: UIColor = UIColor(hexString: "#1C1C1C")
    
    static let textBlack: UIColor = UIColor(hexString: "#343434")
    
    static let textGray: UIColor = UIColor(hexString: "#9A9A9A")
    
    static let imageGray: UIColor = UIColor(hexString: "#DDDDDD")
    
    static let borderGray: UIColor = UIColor(hexString: "#F1F1F1")
    
    static let disabledGray: UIColor = UIColor(hexString: "#E6E6E6")
    
    static let normalGray: UIColor = UIColor(hexString: "#F6F5F5")
}

extension UIFont {
    
    static let navigationBarTitle: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    
    static let textTitle: UIFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    
    static let title: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    
    static let detailTitle: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
}


extension CGFloat {
    var UI: CGFloat {
       let roundingBehavior = NSDecimalNumberHandler(
            roundingMode: .down,
            scale: 2,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let origin = NSDecimalNumber(value: Double(self))
        return CGFloat(origin.rounding(accordingToBehavior: roundingBehavior).doubleValue)
    }
}

extension String {
    
    static let newLine: String = "\n"
}


extension UITableViewCell: Reusable { }


extension UICollectionReusableView: Reusable { }

extension UITableViewHeaderFooterView: Reusable { }

extension UIView: NibLoadable { }


