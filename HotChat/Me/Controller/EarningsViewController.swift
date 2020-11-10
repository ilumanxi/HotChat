//
//  EarningsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit


enum EarningType: Int, CaseIterable {
    case today = 1
    case currentMonth = 2
    case lastMonth = 3
}

class EarningsViewController: UIViewController {
    
    
    @IBOutlet weak var segmentedContainerView: UIStackView!
    
    
    @IBOutlet weak var containerView: UIView!
    
    
    lazy var viewControlers: [UIViewController] = {
        
        return EarningType.allCases.compactMap {
            EarningsDetailViewController(type: $0)
        }
    }()
    
    lazy var pageController: UIPageViewController = {
        
        let contoller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        contoller.dataSource = self
        return contoller
    }()
    
    var scrollView: UIScrollView? {
        return pageController.view.subviews.first { $0 is UIScrollView } as? UIScrollView
    }
    
    var selectedIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的收益"
        setupViews()
        setSelectedIndex(0)
        
        scrollView?.isScrollEnabled = false
    }
    
    func setupViews() {
        addChild(pageController)
        containerView.addSubview(pageController.view)
        pageController.view.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        pageController.didMove(toParent: self)
    }
    
    
    @IBAction func segmentedButtonTapped(_ sender: UIButton) {
        
        let index = segmentedContainerView.subviews.firstIndex(of: sender)!
        setSelectedIndex(index)
    }
    
    
    func setSelectedIndex(_ index: Int) {
        
        selectedIndex = index
        
        for i in 0..<segmentedContainerView.subviews.count {
            let butnton = segmentedContainerView.subviews[i] as! UIButton
            let isSelected: Bool = (i == index)
            butnton.isSelected = isSelected
            butnton.backgroundColor = isSelected ? UIColor(hexString: "#5159F8") : UIColor(hexString: "#F6F5F5")
        }
        
        pageController.setViewControllers([viewControlers[index]], direction: .forward, animated: false, completion: nil)
    }
}

extension EarningsViewController: UIPageViewControllerDataSource {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = viewControlers.firstIndex(of: viewController)!
        
        if index == 0 {
            return nil
        }
        else {
           return viewControlers[index - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = viewControlers.firstIndex(of: viewController)!
        let lastIndex = viewControlers.count - 1
        
        if index == lastIndex {
            return nil
        }
        else {
            return viewControlers[index + 1]
        }
    }
    
    
    
}
