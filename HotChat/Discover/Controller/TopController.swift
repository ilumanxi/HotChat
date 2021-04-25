//
//  TopController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/10.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

extension TopType {
    var index: Int {
        switch  self {
        case .intimate:
            return 0
        case .charm:
            return 1
        case .estate:
            return 2
        }
    }
}

class TopController: TabmanViewController {
    
    var viewControllers: [UIViewController]
    
    lazy var titles: [String] = {
        return TopType.allCases.map{ $0.title }
    }()

    
    let start: TopType
    init(start: TopType = .charm) {
        self.start = start
        viewControllers = [
            IntimateTopViewController(),
            TopViewController(topType: .charm),
            TopViewController(topType: .estate)
        ]
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationBarTintColor = .white
        navigationBarAlpha = 0
        
        let helpItem = UIBarButtonItem(image: UIImage(named: "top-help"), style: .done, target: self, action: #selector(pushHelp))
        navigationItem.rightBarButtonItem = helpItem
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        bounces = false
        // Create a bar
        let bar = Tabman.TMBarView<Tabman.TMHorizontalBarLayout, Tabman.TMLabelBarButton, Tabman.TMBarIndicator.None>()
        // Customize bar properties including layout and other styling.
//        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: insert - 22, bottom: 4.0, right: insert)
        bar.layout.interButtonSpacing = 20
        bar.layout.contentMode = .fit
        bar.indicator.overscrollBehavior = .none
        bar.layout.showSeparators = false
        bar.fadesContentEdges = false
        bar.backgroundView.style = .clear
        
        // Set tint colors for the bar buttons and indicator.
        bar.buttons.customize {
            $0.tintColor = UIColor.white
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.selectedTintColor = UIColor.white
            $0.selectedFont = .systemFont(ofSize: 19, weight: .bold)
        }
        bar.indicator.tintColor = UIColor(hexString: "#FF3F3F")
        let titleView = FitTitleView()
        titleView.setLayouSize(titles: titles, font: .systemFont(ofSize: 19, weight: .bold), spacing:  bar.layout.interButtonSpacing)
        navigationItem.titleView = titleView
        
        addBar(bar.hiding(trigger: .manual), dataSource: self, at: .custom(view: titleView, layout: { view in
            view.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }
        }))
        
       
    }
    
    @objc func pushHelp() {
        let vc = WebViewController.H5(path: "h5/helps/rankHelp")
        navigationController?.pushViewController(vc, animated: true)
    }

    

}


extension TopController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // MARK: PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count // How many view controllers to display in the page view controller.
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        // View controller to display at a specific index for the page view controller.
        viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        // Default page to display in the page view controller (nil equals default/first index).
        return .at(index: start.index)
    }
    
    // MARK: TMBarDataSource
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return TMBarItem(title: titles[index]) // Item to display for a specific index in the bar.
    }
}


