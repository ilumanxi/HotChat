//
//  MeContactViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Pageboy
import Tabman

enum Relationship: Int, CaseIterable {
    case interflow = 3
    case follow = 1
    case fans = 2
    var title: String {
        switch self {
        case .follow:
            return "关注"
        case .fans:
            return "粉丝"
        case .interflow:
            return "聊过的人"
        }
    }
    
    var index: Int {
        switch self {
        case .interflow:
            return 0
        case .follow:
            return 1
        case .fans:
            return 2
        }
    }
}


class MeContactViewController: TabmanViewController {
    
    let startShowRelationship: Relationship
    
    
    init(show relationship: Relationship = .interflow) {
        self.startShowRelationship = relationship
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var titles: [String] = []
    var viewConrollers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的联系人"
        
        view.backgroundColor = .white
        viewConrollers = [
            InterflowViewController(),
            MeRelationshipViewController(relationship: .follow),
            MeRelationshipViewController(relationship: .fans)
        ]
        titles =  Relationship.allCases.map{ $0.title }

        bounces = false
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        
        // Create a bar
        let bar = TMBarView.ButtonBar()
        // Customize bar properties including layout and other styling.
        bar.layout.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        bar.layout.interButtonSpacing = 30
        bar.layout.contentMode = .intrinsic
        bar.indicator.weight = .custom(value: 2.5)
        bar.indicator.cornerStyle = .eliptical
        bar.indicator.overscrollBehavior = .none
        bar.layout.showSeparators = false
        bar.fadesContentEdges = true
        bar.backgroundView.style = .flat(color: .white)
        
        // Set tint colors for the bar buttons and indicator.
        bar.buttons.customize {
            $0.tintColor = UIColor(hexString: "#666666")
            $0.font = .systemFont(ofSize: 17, weight: .regular)
            $0.selectedTintColor = UIColor(hexString: "#333333")
            $0.selectedFont = .systemFont(ofSize: 19, weight: .bold)
        }
        bar.indicator.tintColor = UIColor(hexString: "#FF3F3F")

        addBar(bar.hiding(trigger: .manual), dataSource: self, at: .top)
    }
    

}


extension MeContactViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // MARK: PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewConrollers.count // How many view controllers to display in the page view controller.
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        // View controller to display at a specific index for the page view controller.
        viewConrollers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
         // Default page to display in the page view controller (nil equals default/first index).
        return .at(index: self.startShowRelationship.index)
    }

    
    // MARK: TMBarDataSource
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return TMBarItem(title: titles[index]) // Item to display for a specific index in the bar.
    }
}


