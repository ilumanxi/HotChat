//
//  RecommendViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Pageboy
import Tabman

class RecommendViewController: TabmanViewController {
    
    var titles: [String] = []
    var viewConrollers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        viewConrollers = [UIViewController(), UIViewController()]
        titles = ["推荐用户", "最近活跃"]

        bounces = false
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        
        // Create a bar
        let bar = TMBarView.ButtonBar()
        // 58 = 44 + 14
        let space: CGFloat = view.frame.width - 58.0 - 30.0 - 86 * 2
        let insert: CGFloat = space / 2
        
                
        // Customize bar properties including layout and other styling.
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: insert - 22, bottom: 4.0, right: insert)
        bar.layout.interButtonSpacing = 29.0
        bar.layout.contentMode = .fit
        bar.indicator.weight = .custom(value: 2.5)
        bar.indicator.cornerStyle = .eliptical
        bar.indicator.overscrollBehavior = .none
        bar.layout.showSeparators = false
        bar.fadesContentEdges = true
        bar.spacing = 30.0
        bar.backgroundView.style = .clear
        
        // Set tint colors for the bar buttons and indicator.
        bar.buttons.customize {
            $0.tintColor = UIColor(hexString: "#666666")
            $0.font = .systemFont(ofSize: 17, weight: .regular)
            $0.selectedTintColor = UIColor(hexString: "#333333")
            $0.selectedFont = .systemFont(ofSize: 19, weight: .bold)
        }
        bar.indicator.tintColor = UIColor(hexString: "#FF3F3F")
        
        // Add bar to the view - as a .systemBar() to add UIKit style system background views.
//        addBar(bar.systemBar(), dataSource: self, at: .top)
        
        addBar(bar.hiding(trigger: .manual), dataSource: self, at: .navigationItem(item: navigationItem))
    }
    

}


extension RecommendViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // MARK: PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewConrollers.count // How many view controllers to display in the page view controller.
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        // View controller to display at a specific index for the page view controller.
        viewConrollers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        nil // Default page to display in the page view controller (nil equals default/first index).
    }
    
    // MARK: TMBarDataSource
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return TMBarItem(title: titles[index]) // Item to display for a specific index in the bar.
    }
}

