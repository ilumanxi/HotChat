//
//  UserInfoViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SegementSlide
import HBDNavigationBar
import RxCocoa
import RxSwift
import NSObject_Rx
import SnapKit

class UserInfoViewController: SegementSlideDefaultViewController {
    
    var user: User! {
        didSet {
            refreshData()
        }
    }

    override var bouncesType: BouncesType {
        return .child
    }
    
    lazy var contentTitles: [String] =  {
        return ["资料", "小视频", "动态"]
    }()
    
    lazy var contentViewControllers: [SegementSlideContentScrollViewDelegate] = {
        return contentTitles
            .map { _ in
                let vc = InformationViewController.loadFromStoryboard()
                vc.user = user
                return vc
            }
    }()
    
    override var titlesInSwitcher: [String] {
        return contentTitles
    }
    
    
    private lazy var userInfoHeaderView: UserInfoHeaderView = {
        
        let headerView = UserInfoHeaderView.loadFromNib()
        return headerView
    }()
    
    override func segementSlideHeaderView() -> UIView {
       
        return userInfoHeaderView
    }
    
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        
        return contentViewControllers[index]
    }
    
    
    let dispose = DisposeBag.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultSelectedIndex = 0
        updateNavigationBarStyle(scrollView)
        setupChatView()
        reloadData()
        refreshData()
        
        chatView.onPushing.delegate(on: self) { (self, _) -> (User, UINavigationController) in
            return (self.user, self.navigationController!)
        }
    }
    
    private let chatViewHeight: CGFloat = 48
    
    private var chatView: UserInfoChatView!
    
    
    private func setupChatView() {
        
        chatView = UserInfoChatView.loadFromNib()
        chatView.backgroundColor = .clear
        view.addSubview(chatView)
        
        chatView.snp.makeConstraints { maker in
            maker.height.equalTo(48)
            maker.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(self.safeBottom).offset(-20).priority(999)
            maker.bottom.equalToSuperview().offset(-34)
        }
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView, isParent: Bool) {
        super.scrollViewDidScroll(scrollView, isParent: isParent)
        guard isParent else {
            return
        }
        updateNavigationBarStyle(scrollView)
    }
    
    private func updateNavigationBarStyle(_ scrollView: UIScrollView) {
       
        var alpha = max(min(scrollView.contentOffset.y / headerStickyHeight, 1), 0)
        
        if alpha.isNaN {
            alpha = 0
        }
        
        let color = UIColor.textBlack.withAlphaComponent(alpha)

        hbd_barAlpha = Float(alpha)
        hbd_titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : color]
          hbd_setNeedsUpdateNavigationBar()
    }
    
    func refreshData() {
        userInfoHeaderView.user = user
    }
    
}
