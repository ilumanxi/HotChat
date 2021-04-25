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

class RecommendContainerController: TabmanViewController {
    
    var titles: [String] = []
    var viewConrollers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        viewConrollers = [RecommendViewController(type: .recommend), RecommendViewController(type: .active)]
        titles = ["推荐用户", "最近活跃"]

        bounces = false
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        
        // Create a bar
        let bar = TMBarView.ButtonBar()
        // Customize bar properties including layout and other styling.
//        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: insert - 22, bottom: 4.0, right: insert)
        bar.layout.interButtonSpacing = 30
        bar.layout.contentMode = .fit
        bar.indicator.weight = .custom(value: 2.5)
        bar.indicator.cornerStyle = .eliptical
        bar.indicator.overscrollBehavior = .none
        bar.layout.showSeparators = false
        bar.fadesContentEdges = false
        bar.backgroundView.style = .clear
        
        // Set tint colors for the bar buttons and indicator.
        bar.buttons.customize {
            $0.tintColor = UIColor(hexString: "#666666")
            $0.font = .systemFont(ofSize: 17, weight: .regular)
            $0.selectedTintColor = UIColor(hexString: "#333333")
            $0.selectedFont = .systemFont(ofSize: 19, weight: .bold)
        }
        bar.indicator.tintColor = UIColor(hexString: "#FF3F3F")
        let titleView = FitTitleView()
        titleView.setLayouSize(titles: titles, font: .systemFont(ofSize: 19, weight: .bold), spacing: 30)
        navigationItem.titleView = titleView
        
        addBar(bar.hiding(trigger: .manual), dataSource: self, at: .custom(view: titleView, layout: { view in
            view.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }
        }))
    }
    

}


extension RecommendContainerController: PageboyViewControllerDataSource, TMBarDataSource {
    
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

