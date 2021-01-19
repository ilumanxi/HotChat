//
//  ConsumptionListController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Aquaman
import Trident

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

class ConsumptionListController: AquamanPageViewController {
    
    lazy var menuView: TridentMenuView = {
        let view = TridentMenuView(parts:
            .normalTextColor(UIColor(hexString: "#666666")),
            .selectedTextColor(UIColor(hexString: "#1B1B1B")),
            .normalTextFont(UIFont.systemFont(ofSize: 14.0, weight: .medium)),
            .selectedTextFont(UIFont.systemFont(ofSize: 19.0, weight: .bold)),
            .switchStyle(.line),
            .sliderStyle(
                SliderViewStyle(parts:
                    .backgroundColor(.theme),
                    .height(2.5),
                    .cornerRadius(1.5),
                    .position(.bottom),
                    .extraWidth(0),
                    .shape(.line)
                )
            ),
            .bottomLineStyle(
                BottomLineViewStyle(parts:
                    .hidden(true)
                )
            )
        )
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.backgroundColor = .white
        view.delegate = self
        return view
    }()
    
    let headerView = UIView()
    let headerViewHeight: CGFloat = 1
    private var menuViewHeight: CGFloat = 44.0
    
    
    lazy var contentViewControllers: [ConsumerDetailsViewController] = {
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
        
        menuView.titles = contentViewControllers.compactMap{ $0.title }
        
        reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return headerView
    }
    
    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return headerViewHeight
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        return contentViewControllers.count
    }
    
    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
        return contentViewControllers[index]
    }
    
    // 默认显示的 ViewController 的 index
    override func originIndexFor(_ pageController: AquamanPageViewController) -> Int {
       return 0
    }
    
    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return menuView
    }
    
    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return menuViewHeight
    }
    
    override func menuViewPinHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return 0
    }

    
    override func pageController(_ pageController: AquamanPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        
    }
    
    override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }
    
    override func pageController(_ pageController: AquamanPageViewController,
                                 contentScrollViewDidEndScroll scrollView: UIScrollView) {
        
    }
    
    override func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool) {

    }
    
    
    override func pageController(_ pageController: AquamanPageViewController, willDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
    }
    
    override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        menuView.checkState(animation: true)
    }
    
    override func contentInsetFor(_ pageController: AquamanPageViewController) -> UIEdgeInsets {
        return .zero
    }
    
}

extension ConsumptionListController: TridentMenuViewDelegate {
    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < contentViewControllers.count else {
            return
        }
        setSelect(index: index, animation: false)
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
