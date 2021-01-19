//
//  UserInfoViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Aquaman
import Trident
import HBDNavigationBar
import RxCocoa
import RxSwift
import NSObject_Rx
import SnapKit

class UserInfoViewController: AquamanPageViewController, LoadingStateType, IndicatorDisplay {
    
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
//                    .extraWidth(indexPath.row == 0 ? -10.0 : 4.0),
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
    
    
    var headerViewHeight: CGFloat {
        
        return 110.0 + view.bounds.width
    }
    private var menuViewHeight: CGFloat = 54.0
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    
    var user: User! {
        didSet {
            userInfoHeaderView.user = user
        }
    }
    
    override var backBarButtonImage: UIImage? {
        
        return UIImage(named: "circle-back-white")
    }
    
    lazy var viewControllers: [UIViewController] =  {
        let information = InformationViewController.loadFromStoryboard()
        information.title = "资料"
        information.user = user
        
        let dynamic = DynamicDetailViewController.loadFromStoryboard()
        dynamic.title = "动态"
        dynamic.user = user
        
        return [
            information,
            dynamic
        ]
    }()
    
    

    
    
    private lazy var userInfoHeaderView: UserInfoHeaderView = {
        let headerView = UserInfoHeaderView.loadFromNib()
        headerView.onFollowButtonTapped.delegate(on: self) { (self, sender) in
            sender.followButton.isUserInteractionEnabled = false
            self.dynamicAPI.request(.follow(self.user.userId), type: ResponseEmpty.self)
                .verifyResponse()
                .subscribe(onSuccess: { response in
                    sender.followButton.isUserInteractionEnabled = true
                    var user = self.user
                    user?.isFollow = true
                    self.user = user
                    self.show(response.msg)
                }, onError: { error in
                    sender.followButton.isUserInteractionEnabled = true
                    self.show(error)
                })
                .disposed(by: self.rx.disposeBag)
        }
        return headerView
    }()
    
    let userAPI = Request<UserAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        edgesForExtendedLayout = .all
//        defaultSelectedIndex = 0
        updateNavigationBarStyle(mainScrollView)
        navigationItem.title = user.nick
        menuView.titles = viewControllers.compactMap{ $0.title }
        if user.userId != LoginManager.shared.user!.userId {
            setupChatView()
        }
        reloadData()
        
        state = .loadingContent
        refreshData()
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupNavigationItem() {
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: backBarButtonImage, style: .plain, target: self, action: #selector(pop)), animated: true)
        
        if user.userId == LoginManager.shared.user!.userId {
            let more = UIBarButtonItem(image: UIImage(named: "circle-edit-white"), style: .plain, target: self, action: #selector(editItemTapped))
            self.navigationItem.rightBarButtonItems = [more]
        }
        else {
            let more = UIBarButtonItem(image: UIImage(named: "circle-more-white"), style: .plain, target: self, action: #selector(moreItemTapped))
            self.navigationItem.rightBarButtonItems = [more]
        }
    }
    
    @objc func editItemTapped() {
        let vc  = UserInfoEditingViewController.loadFromStoryboard()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func moreItemTapped() {
        let vc  = UserSettingViewController.loadFromStoryboard()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshData() {
        state = .refreshingContent
        userAPI.request(.userinfo(userId: user.userId),type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data
                self?.setupNavigationItem()
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewState()
    }
    
    private let chatViewHeight: CGFloat = 48
    
    private var chatView: UserInfoChatView!
    
    let API = Request<ChatGreetAPI>()
    
    func chatViewState() {
        if LoginManager.shared.user!.girlStatus {
            API.request(.checkGreet(toUserId: user.userId), type: Response<[String : Any]>.self)
                .verifyResponse()
                .subscribe(onSuccess: { [weak self] response in

                    guard let resultCode = response.data?["resultCode"] as? Int else { return }
                    
                    if resultCode == 1005 {
                        self?.chatView?.state = .sayHellow
                    }
                    else if resultCode == 1006 {
                        self?.chatView?.state = .default
                    }
                    else if resultCode == 1007 {
                        self?.chatView?.state = .notSayHellow
                    }
                    
                }, onError: nil)
                .disposed(by: rx.disposeBag)
        }
    }
    
    
    private func setupChatView() {
        
        chatView = UserInfoChatView.loadFromNib()
        chatView.onSayHellowed.delegate(on: self) { (self, _) in
            self.chatView.state = .notSayHellow
            self.chatViewState()
        }
        chatView.onPushing.delegate(on: self) { (self, _) -> (User, UINavigationController) in
            return (self.user, self.navigationController!)
        }
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
    
    
    private func updateNavigationBarStyle(_ scrollView: UIScrollView) {
       
        var alpha = max(min(scrollView.contentOffset.y / headerViewHeight, 1), 0)
        
        if alpha.isNaN {
            alpha = 0
        }
        
        if alpha < 0.5 {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "circle-back-white")
            if user.userId == LoginManager.shared.user!.userId {
                navigationItem.rightBarButtonItem?.image = UIImage(named: "circle-edit-white")
            }
            else {
                navigationItem.rightBarButtonItem?.image = UIImage(named: "circle-more-white")
            }
        }
        else {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "navigation-bar-back")
            
            if user.userId == LoginManager.shared.user!.userId {
                navigationItem.rightBarButtonItem?.image = UIImage(named: "edit-gray")
            }
            else {
                navigationItem.rightBarButtonItem?.image =  UIImage(named: "more-gray")
            }
        }
        
        let color = UIColor.textBlack.withAlphaComponent(alpha)

        hbd_barAlpha = Float(alpha)
//        hbd_barTintColor = UIColor.white.withAlphaComponent(alpha)
        hbd_titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : color]
        hbd_setNeedsUpdateNavigationBar()
    }
    
    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return userInfoHeaderView
    }
    
    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return headerViewHeight
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        return viewControllers.count
    }
    
    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
        return viewControllers[index] as! AquamanChildViewController
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
        return (UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0))
    }

    
    override func pageController(_ pageController: AquamanPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        updateNavigationBarStyle(scrollView)
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
        return UIEdgeInsets(
            top: -(UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0)),
            left: 0,
            bottom: 0,
            right: 0
        )
    }
    
}

extension UserInfoViewController: TridentMenuViewDelegate {
    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < viewControllers.count else {
            return
        }
        setSelect(index: index, animation: false)
    }
}

