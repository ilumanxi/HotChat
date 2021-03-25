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
import Trident

class TopController: PageboyViewController {
    
    lazy var viewControllers: [TopViewController] = {
        
        return TopType.allCases.compactMap {
            let vc  = TopViewController(topType: $0)
            vc.title = $0.title
            return vc
        }
    }()
    
    
    lazy var titleView: UIStackView = {
        var buttons = [UIButton]()
        
        for top in  TopType.allCases {
            let button = UIButton(type: .custom)
            button.setAttributedTitle(
                NSAttributedString(
                    string: top.title,
                    attributes: [
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium),
                        NSAttributedString.Key.foregroundColor: top.textColor
                    ]),
                for: .normal)
            button.setAttributedTitle(
                NSAttributedString(
                    string: top.title,
                    attributes: [
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19, weight: .bold),
                        NSAttributedString.Key.foregroundColor: top.selectedTextColor
                    ]),
                for: .selected)
            button.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        let view = UIStackView(arrangedSubviews: buttons)
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .equalCentering
        view.spacing = 30
        return view
    }()
    
    var selectIndex: Int
    let start: TopType

    init(start: TopType = .charm) {
        self.start = start
        selectIndex = start.rawValue - 1
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        hbd_barAlpha = 0
        hbd_tintColor = .white
        
        let item = UIBarButtonItem(image: UIImage(named: "top-help"), style: .plain, target: self, action: #selector(pushHelp))
        
        navigationItem.rightBarButtonItem = item
        
        view.backgroundColor = .white
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        isScrollEnabled = false
        bounces = false
        
        navigationItem.titleView = titleView
        titleView(select:selectIndex)
        
    }
    
    @objc func pushHelp() {
        
        let vc = WebViewController.H5(path: "h5/helps/rankHelp")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func didSelect(_ button: UIButton) {
        let buttons = titleView.arrangedSubviews.compactMap{ $0 as? UIButton }
        
        guard let index = buttons.firstIndex(of: button) else { return  }
        
        if self.selectIndex == index {
            return
        }
        
        titleView(select: index)
  
    }

    
    func titleView(select index: Int) {
                
        self.selectIndex = index
        
        let buttons = titleView.arrangedSubviews.compactMap{ $0 as? UIButton }
        
        for i in 0..<buttons.count {
            buttons[i].isSelected = index == i
        }
        
        UIView.animate(withDuration: 0.25) {
            self.titleView.superview?.layoutIfNeeded()
        }
        
        scrollToPage(.at(index: index), animated: false)
    }
}


// MARK: PageboyViewControllerDataSource

extension TopController: PageboyViewControllerDataSource {
    
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count // How many view controllers to display in the page view controller.
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index] // View controller to display at a specific index for the page view controller.
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: selectIndex)
    }

    // MARK: Actions

    @objc func nextPage() {
        scrollToPage(.next, animated: false)
    }

    @objc func previousPage() {
        scrollToPage(.previous, animated: false)
    }

}

