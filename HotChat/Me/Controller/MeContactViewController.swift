//
//  MeContactViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SegementSlide



enum Relationship: Int, CaseIterable {
    case follow = 1
    case fans = 2
    
    var title: String {
        switch self {
        case .follow:
            return "关注"
        case .fans:
            return "粉丝"
        }
    }
}

class MeContactViewController: SegementSlideDefaultViewController {
    
    
    let startShowRelationship: Relationship
    
    
    lazy var contentTitles: [String] =  {
        return Relationship.allCases.map { $0.title }
    }()
    
    lazy var contentViewControllers: [MeRelationshipViewController] = {
        return Relationship.allCases
            .map {
                let vc = MeRelationshipViewController(style: .plain)
                vc.relationship = $0
                return vc
            }
    }()
    
    override var titlesInSwitcher: [String] {
        return contentTitles
    }
    
    init(show relationship: Relationship) {
        self.startShowRelationship = relationship
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的联系人"
        
        defaultSelectedIndex = startShowRelationship.rawValue - 1
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
