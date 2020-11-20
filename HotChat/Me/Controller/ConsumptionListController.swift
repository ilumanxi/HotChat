//
//  ConsumptionListController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SegementSlide

enum Checklist: CaseIterable {
    case all
    case earn
    case expenditure
    case recharge
    case earning
}

class ConsumptionListController: SegementSlideDefaultViewController {
    
    
    lazy var contentViewControllers: [ConsumerDetailsViewController] = {
        return Checklist.allCases
            .map {
                let vc = ConsumerDetailsViewController(type: $0)
                vc.title = $0.text
                return vc
            }
    }()
    
    override var titlesInSwitcher: [String] {
        return contentViewControllers.compactMap{ $0.title }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "明细"
        
        defaultSelectedIndex = 0
        reloadData()

        // Do any additional setup after loading the view.
    }
    
    override var bouncesType: BouncesType {
        return .child
    }
    
    override var switcherConfig: SegementSlideDefaultSwitcherConfig {
        var config = super.switcherConfig
        config.type = .tab
        return config
    }
    
    override func showBadgeInSwitcher(at index: Int) -> BadgeType {
        return .none
    }
    

    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        
        return contentViewControllers[index]
    }
    

}


extension Checklist {
    
    var text: String {
        switch self {
        case .all:
            return "全部"
        case .earn:
            return "获得"
        case .expenditure:
            return "消耗"
        case .recharge:
            return "充值"
        case .earning:
            return "收益"
        }
    }
}
