//
//  UITableView+App.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

extension UITableView {
    
    var hiddenView: UIView {
        let hiddenFrame = CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        return UIView(frame: hiddenFrame)
    }
    
    
    func hiddenHeader() {
        tableHeaderView = hiddenView
    }
    
    func hiddenFoooter()  {
        tableFooterView = hiddenView
    }
}
