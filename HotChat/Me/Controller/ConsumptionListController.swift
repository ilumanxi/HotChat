//
//  ConsumptionListController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Pageboy
import Tabman

enum Checklist: CaseIterable {
    case all
    case earn
    case expenditure
    case recharge
    case earning
    case conversion
}

enum ChecklistType {
    case earnings
    case wallet
}

extension ChecklistType {
    
    var list: [Checklist] {
        switch self {
        case .earnings:
            return [.all , .earning, .conversion]
        default:
            return [.all, .earn, .expenditure, .recharge]
        }
    }
}

class ConsumptionListController: TabmanViewController {
    
    
    lazy var viewControllers: [ConsumerDetailsViewController] = {
        return type.list
            .map {
                let vc = ConsumerDetailsViewController(type: $0, dataType: type)
                vc.title = $0.text
                return vc
            }
    }()
    

    let type: ChecklistType
    
    init(type: ChecklistType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "明细"
        
        bounces = false
        
        if let pageViewController = self.children.first as? UIPageViewController {
            let scrollView =  pageViewController.view.subviews.first { $0 is UIScrollView } as? UIScrollView
            if let popGesture = navigationController?.interactivePopGestureRecognizer {
                scrollView?.panGestureRecognizer.require(toFail: popGesture)
            }
        }
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


extension ConsumptionListController: PageboyViewControllerDataSource, TMBarDataSource {
    
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
        return nil
    }

    
    // MARK: TMBarDataSource
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return TMBarItem(title: viewControllers[index].title!) // Item to display for a specific index in the bar.
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
            return "每日收益"
        case .conversion:
            return "兑换"
        }
    }
}
